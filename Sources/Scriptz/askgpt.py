from random import random
from time import sleep

import openai

GPT35_16 = "gpt-3.5-turbo-16k"
GPT35 = "gpt-3.5-turbo"
GPT4 = "gpt-4"
openai.api_key = "..."


def list_models():
    models = openai.Model.list()
    f = open("models.json", "w")
    f.write(str(models))
    f.close()


def response(history, model=GPT4):
    completion = openai.ChatCompletion.create(
        model=model, messages=history, max_tokens=2000
    )
    response = completion.choices[0].message.content
    return response


def ask(initial_prompt, prompts, model=GPT35):
    history = [{"role": "system", "content": initial_prompt}]
    responses = []

    for i, prompt in enumerate(prompts):
        if prompt.startswith("$$$nochange:"):
            responses.append(prompt)
            continue
        if i % 10 == 0:
            sleep(random())

        new_message = {"role": "user", "content": prompt}
        result = response(history + [new_message], model)
        responses.append(result)

    return responses


if __name__ == "__main__":
    list_models()
