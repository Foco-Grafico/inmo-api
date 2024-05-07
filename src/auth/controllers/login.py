from pydantic import BaseModel
from fastapi import HTTPException, Depends, Form
from fastapi.responses import JSONResponse, RedirectResponse
from src.services.turso import DB
from typing import Annotated
from bcrypt import checkpw

class LoginUserRequest(BaseModel):
    email: str | None = None
    phone_number: str | None = None
    password: str

    @classmethod
    def as_form(
        cls,
        password: Annotated[str, Form()],
        email: Annotated[str | None, Form()] = None,
        phone_number: Annotated[str | None, Form()] = None
    ):
        return cls(
            email=email,
            phone_number=phone_number,
            password=password
    )


def decode_url(url: str):
    return url.replace('%2F', '/')

async def login_user(redirect: str | None = None, current_path: str | None = None, request_user: LoginUserRequest = Depends(LoginUserRequest.as_form)):
    db = DB()

    try:
        user = db.select(['token']).from_table('users').where({
            'email': request_user.email
        }).or_where({
            'phone_number': request_user.phone_number
        }).single_execute()
    except:
        if current_path is not None:
            return RedirectResponse(url=f'{decode_url(current_path)}?error=An error has occurred')

        # Error has occurred when user is not found
        raise HTTPException(status_code=404, detail='An error has occurred')
    
    if user is None:
        # User is not found
        if current_path is not None:
            return RedirectResponse(url=f'{decode_url(current_path)}?error=User not found')

        raise HTTPException(status_code=404, detail='User not found')
    
    if not checkpw(request_user.password.encode('utf-8'), user['token'].encode('utf-8')):
        if current_path is not None:
            return RedirectResponse(url=f'{decode_url(current_path)}?error=Invalid password')

        raise HTTPException(status_code=401, detail='Invalid password')

    if redirect is not None:
        response = RedirectResponse(url=decode_url(redirect))
    else:
        response = JSONResponse(content={
            'message': 'User logged in successfully',
            'token': user['token']
        })

    response.set_cookie(key='token', value=user['token'])

    return response