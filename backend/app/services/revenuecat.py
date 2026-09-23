"""Removes a deleted account's RevenueCat customer record (App Store
account-deletion requirement). Needs the RevenueCat secret key."""

import httpx


async def delete_customer(
    http: httpx.AsyncClient, secret_key: str, app_user_id: str
) -> bool:
    """True if deleted (or already gone); False if it couldn't be done."""
    if not secret_key:
        return False
    try:
        r = await http.delete(
            f"https://api.revenuecat.com/v1/subscribers/{app_user_id}",
            headers={"authorization": f"Bearer {secret_key}"},
            timeout=10,
        )
    except httpx.HTTPError:
        return False
    return r.status_code in (200, 204, 404)
