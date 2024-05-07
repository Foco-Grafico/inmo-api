from fastapi import Body
from typing import Annotated
from src.services.turso import DB

async def is_logged(token: Annotated[str | None, Body(..., embed=True)] = None):
    db = DB()

    try:
        user = db.select([
            'token'
        ]).from_table('users').where({
            'token': token
        }).single_execute()
    except:
        return {
            'value': False
        }

    if not user:
        return {
            'value': False
        }

    return {
        'value': True
    }