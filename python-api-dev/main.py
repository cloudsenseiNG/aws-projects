from fastapi import FastAPI
from fastapi.params import Body
from pydantic import BaseModel
from typing import Optional
from random import randrange

default = FastAPI()

class Post(BaseModel):
    title: str
    content: str
    published: bool = True
    rating: Optional[int] = None

def post_id(id):
    for post in my_posts:
        if post["id"] == id:
            return post    

my_posts = [{"title": "Fancy Title", "content": "This is a Fancy Title", "id": 1}, {"title": "New Title", "content": "This is a new title", "id": 2}]

@default.get("/")
async def root():
    return {"message": "Demo"}

@default.get("/posts")
async def get_item():
    return {"data": my_posts}

@default.post("/posts")
async def post_item(post: Post):
    python_dict = post.model_dump()
    python_dict['id'] = randrange(1, 20000)
    my_posts.append(python_dict)
    return {"post": python_dict}

@default.get("/posts/{id}")
async def get_post_id(id: int):
    get_post = post_id(id)
    return {"data": get_post}