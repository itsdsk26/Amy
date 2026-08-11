# Happy Birthday Page

Simple static page `happy_birthday.html` to wish someone a happy birthday.

How to publish to GitHub:

1. Initialize a git repo locally:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
```

2. Create a GitHub repo and push (choose one):

- Using `gh` CLI:

```bash
gh repo create <OWNER>/<REPO> --public --source=. --push
```

- Or manually on GitHub: create a new repo, then:

```bash
git remote add origin https://github.com/<OWNER>/<REPO>.git
git push -u origin main
```

3. After pushing, the included GitHub Actions workflow will deploy the site to GitHub Pages on the `gh-pages` branch automatically.

Site URL: `https://<OWNER>.github.io/<REPO>/` (replace `<OWNER>` and `<REPO>` accordingly).
