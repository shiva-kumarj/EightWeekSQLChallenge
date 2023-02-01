This is my attempt at Danny Ma's 8 Week SQL challenge. Periodically, I will be committing my solution to the questions.

## How to push code into different repositories from the same system

### Setting it up
As an example, let's say you're working on multiple repositories hosted at the same domain name.

| Repo URL | Identity |
| --- | --- |
| https://example.com/open-source/library.git | contrib123 |
| https://example.com/more-open-source/app.git | contrib123 |
| https://example.com/big-company/secret-repo.git | employee9999 |


When you clone these repos, include the identity and an @ before the domain name in order to force Git and GCM to use different identities. If you've already cloned the repos, you can update the remote URL to include the identity.



### Example: fresh clones

- instead of `git clone https://example.com/open-source/library.git`, run:
git clone https://contrib123@example.com/open-source/library.git

- instead of `git clone https://example.com/big-company/secret-repo.git`, run:
git clone https://employee9999@example.com/big-company/secret-repo.git

### Example: existing clones
- in the `library` repo, run:
git remote set-url origin https://contrib123@example.com/open-source/library.git

- in the `secret-repo` repo, run:
git remote set-url origin https://employee9999@example.com/big-company/secret-repo.git