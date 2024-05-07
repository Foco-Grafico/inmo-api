from fastapi import Request, Response
# from fastapi.responses import RedirectResponse
from typing import Callable
from src.services.turso import DB
from functools import reduce

permitted_paths = [
    '/auth',
    '/docs',
    '/openapi.json',
    '/health'
]


async def middleware(
    request: Request,
    next: Callable[[], Response]
):
    db = DB()

    token = request.cookies.get('token')

    pathname = request.url.path

    try:
        user = db.select(['token']).from_table('users').where({
            'token': token
        }).single_execute()
    except:
        user = None

    valid_perms = list(map(lambda path: pathname.startswith(path), permitted_paths))

    if reduce(
        lambda acc, perm: acc or perm, # type: ignore
        valid_perms,
        False
    ):
        return next()

    if user is None:
        return Response(status_code=401)
    
    return next()