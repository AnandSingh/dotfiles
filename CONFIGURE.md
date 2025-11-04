# Configuration Steps

Before using your dotfiles, you need to update a few files with your GitHub username.

## Required Changes

### 1. Update remote-install.sh

Open `remote-install.sh` and change line 16:

```bash
# FROM:
REPO_URL="https://github.com/YOUR_USERNAME/dotfiles.git"

# TO:
REPO_URL="https://github.com/YOUR_ACTUAL_USERNAME/dotfiles.git"
```

### 2. Update README.md

Search and replace all instances of `YOUR_USERNAME` with your actual GitHub username.

Quick command to do this:
```bash
# Replace YOUR_USERNAME with your actual username
sed -i '' 's/YOUR_USERNAME/your-actual-username/g' README.md
sed -i '' 's/YOUR_USERNAME/your-actual-username/g' INSTALL.md
sed -i '' 's/YOUR_USERNAME/your-actual-username/g' remote-install.sh

# For Linux, use:
sed -i 's/YOUR_USERNAME/your-actual-username/g' README.md
sed -i 's/YOUR_USERNAME/your-actual-username/g' INSTALL.md
sed -i 's/YOUR_USERNAME/your-actual-username/g' remote-install.sh
```

### 3. Commit and Push

After making these changes:

```bash
git add .
git commit -m "Update repository URLs with actual GitHub username"
git push
```

---

## Your Custom Curl Command

After updating the files, your installation command will be:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_ACTUAL_USERNAME/dotfiles/main/remote-install.sh)
```

**Save this command somewhere safe!** You'll use it to set up new machines.

---

## Optional: Create a Short URL

For an even easier setup, create a short URL using a service like:

- [bit.ly](https://bitly.com)
- [tinyurl.com](https://tinyurl.com)
- [git.io](https://git.io) (GitHub's URL shortener)

Example:
```bash
# Instead of the long URL, you could have:
bash <(curl -fsSL https://bit.ly/your-dotfiles)
```

---

## Test Your Setup

Test your configuration on a VM or container:

```bash
# Using Docker (Ubuntu)
docker run -it ubuntu:latest bash
# Then run your curl command

# Using Docker (Fedora)
docker run -it fedora:latest bash
# Then run your curl command
```

---

## Additional Customization

### Update Git Config

Edit `git/.gitconfig` with your information:

```bash
[user]
    name = Your Name
    email = your.email@example.com
```

### Update Private Configs

Edit `zsh/.bashrc_private` for machine-specific settings:

```bash
# API keys
export OPENAI_API_KEY="your-key"

# Custom paths
export PATH="$HOME/custom/bin:$PATH"

# Aliases
alias work="cd ~/work"
```

This file is already in `.zshrc` and will be sourced automatically.

---

## All Done!

Once you've completed these steps:

1. ✅ Updated repository URLs
2. ✅ Committed and pushed changes
3. ✅ Tested the curl command
4. ✅ Customized git config and private settings

You're ready to use your dotfiles on any new machine!
