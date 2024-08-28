# FunnyScript

## Interpreter
FunnyScript is a language for telling stories.
A FunnyScript file is just called a `script`.
Scripts are interpreted by Funnybot, our app, to generate videos.
Right now it only supports dialogs and everything else is handled automatically by the rendering engine or added in post.

## Subject
Each line of the script needs to have a subject.
A subject must be one of the following:
- The name of single a character, lowercase (such as `roy` or `dan`), see "Subject Directives" 
- The word `scene`, see "Scene Directives"
- The word `overlay`, see "Scene Directives"
- The word `camera`, see "Camera Directives"

A subject cannot refer to a group of subject. For example, if "Roy, Dan and Bella say hello", add one line for each character:
```
roy: "hello"
dan: "hello"
bella: "hello"
```

## Dialogs
`<subject>: "<<emotion>><spoken text>" [<additional_info>]`

Examples:
* `andy: "Hello World!"`
* `andy: "<embarassed>Oh, hi Bella!" he said blushing`
* `dan: "<angrily>Shut up!"`
