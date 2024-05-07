from fastapi import Cookie, HTTPException
from typing import Annotated
from src.services.turso import DB

async def get_user(token: Annotated[str | None, Cookie()] = None):
    if token is None:
        raise HTTPException(status_code=401, detail='Unauthorized')

    db = DB()

    try:
        user = db.select().from_table('users').where({
            'token': token
        }).single_execute()
    except:
        raise HTTPException(status_code=404, detail='User not found')
    
    if user is None:
        raise HTTPException(status_code=404, detail='User not found')

    return user