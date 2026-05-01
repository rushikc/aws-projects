"""Start/stop EC2 instances and RDS DB instances tagged with a given key/value."""

import json
import logging
import os
from typing import Any

import boto3
from botocore.exceptions import ClientError

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)

TAG_KEY = os.environ.get("TAG_KEY", "Environment")
TAG_VALUE = os.environ.get("TAG_VALUE", "Dev")
EC2_TYPE = "ec2:instance"
RDS_TYPE = "rds:db"


def _tagged_arns(tagging: Any, resource_types: list[str]) -> list[str]:
    arns: list[str] = []
    paginator = tagging.get_paginator("get_resources")
    for page in paginator.paginate(
        ResourceTypeFilters=resource_types,
        TagFilters=[{"Key": TAG_KEY, "Values": [TAG_VALUE]}],
    ):
        for item in page.get("ResourceTagMappingList", []):
            arn = item.get("ResourceARN")
            if arn:
                arns.append(arn)
    return arns


def _ec2_instance_id(arn: str) -> str | None:
    if ":instance/" in arn:
        return arn.split("instance/", 1)[-1]
    return None


def _rds_db_identifier(arn: str) -> str | None:
    if ":db:" in arn:
        return arn.rsplit(":db:", 1)[-1]
    return None


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    action = (event or {}).get("action")
    if action not in ("start", "stop"):
        LOG.error("event.action must be 'start' or 'stop', got: %s", action)
        return {"ok": False, "error": "invalid action"}

    tagging = boto3.client("resourcegroupstaggingapi")
    ec2 = boto3.client("ec2")
    rds = boto3.client("rds")

    arns = _tagged_arns(tagging, [EC2_TYPE, RDS_TYPE])
    ec2_ids = sorted({i for a in arns if (i := _ec2_instance_id(a))})
    rds_ids = sorted({i for a in arns if (i := _rds_db_identifier(a))})

    LOG.info(
        "action=%s tag=%s:%s ec2_count=%s rds_count=%s",
        action,
        TAG_KEY,
        TAG_VALUE,
        len(ec2_ids),
        len(rds_ids),
    )

    errors: list[str] = []

    if ec2_ids:
        try:
            if action == "stop":
                ec2.stop_instances(InstanceIds=ec2_ids)
                LOG.info("ec2 stop requested: %s", ec2_ids)
            else:
                ec2.start_instances(InstanceIds=ec2_ids)
                LOG.info("ec2 start requested: %s", ec2_ids)
        except ClientError as e:
            LOG.exception("ec2 %s failed", action)
            errors.append(f"ec2: {e}")

    for db_id in rds_ids:
        try:
            if action == "stop":
                rds.stop_db_instance(DBInstanceIdentifier=db_id)
                LOG.info("rds stop requested: %s", db_id)
            else:
                rds.start_db_instance(DBInstanceIdentifier=db_id)
                LOG.info("rds start requested: %s", db_id)
        except ClientError as e:
            code = e.response.get("Error", {}).get("Code", "")
            if code in ("InvalidDBInstanceState", "DBInstanceNotFound"):
                LOG.warning("rds %s skip %s: %s", action, db_id, e)
            else:
                LOG.exception("rds %s failed for %s", action, db_id)
                errors.append(f"rds {db_id}: {e}")

    body = {
        "action": action,
        "tag": f"{TAG_KEY}={TAG_VALUE}",
        "ec2_instance_ids": ec2_ids,
        "rds_db_identifiers": rds_ids,
        "errors": errors,
    }
    return {"statusCode": 200 if not errors else 207, "body": json.dumps(body)}
