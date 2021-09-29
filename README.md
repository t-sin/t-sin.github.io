# t-sin.github.io

This website is generated with [Asha](https://github.com/t-sin/asha) the static site generator.

## How to publish

1. write an article
2. add the article with `asha add article techblog ./techblog/YYYY-MM-DD_hoge.md`
3. generate HTML files with `asha publish ./docs`
4. check the article generated as HTML
5. commit the article
6. switch branch with `git switch public`
7. publish the article with `./publish.sh`
8. push the article with `git push origin public`
