#!/usr/bin/env python3
"""
Deletes all DigitalOcean snapshots named 'vectora-snapshot'
before a new Packer build runs.
"""

import urllib.request
import urllib.error
import json
import sys
import os

def cleanup_snapshots(token: str, snapshot_name: str = "vectora-snapshot"):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    print(f"🔍 Looking for old snapshots named '{snapshot_name}'...")

    # Fetch all droplet snapshots
    req = urllib.request.Request(
        "https://api.digitalocean.com/v2/snapshots?resource_type=droplet&per_page=200",
        headers=headers
    )

    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
    except urllib.error.HTTPError as e:
        print(f"❌ Failed to fetch snapshots: {e}")
        print(f"Response: {e.read().decode()}")
        sys.exit(1)

    # Show ALL snapshots found (for debugging)
    all_snapshots = data.get("snapshots", [])
    print(f"📋 Total snapshots found: {len(all_snapshots)}")
    for s in all_snapshots:
        print(f"   - {s['name']} (ID: {s['id']}, created: {s['created_at']})")

    # Filter snapshots by name
    matching = [s for s in all_snapshots if s["name"] == snapshot_name]

    if not matching:
        print("✅ No old snapshots found. Nothing to clean up.")
        return

    print(f"🗑️  Found {len(matching)} snapshot(s) to delete.")

    # Delete each matching snapshot
    deleted = 0
    for snapshot in matching:
        snapshot_id = snapshot["id"]
        created_at  = snapshot["created_at"]
        print(f"   Deleting snapshot {snapshot_id} (created: {created_at})...")

        del_req = urllib.request.Request(
            f"https://api.digitalocean.com/v2/snapshots/{snapshot_id}",
            headers=headers,
            method="DELETE"
        )

        try:
            urllib.request.urlopen(del_req)
            print(f"   ✅ Deleted snapshot {snapshot_id}")
            deleted += 1
        except urllib.error.HTTPError as e:
            print(f"   ❌ Failed to delete {snapshot_id}: {e}")
            print(f"   Response: {e.read().decode()}")

    print(f"🎉 Cleanup complete. Deleted {deleted}/{len(matching)} snapshot(s).")


if __name__ == "__main__":
    # Read token from environment variable
    token = os.environ.get("DIGITALOCEAN_TOKEN")

    if not token:
        print("❌ Error: DIGITALOCEAN_TOKEN environment variable not set.")
        sys.exit(1)

    cleanup_snapshots(token)