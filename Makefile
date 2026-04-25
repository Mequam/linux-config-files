.PHONY: restow stow unstow

stow:
	stow .

unstow:
	stow -D .

restow: unstow stow

