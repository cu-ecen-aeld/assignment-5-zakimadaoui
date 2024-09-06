
##############################################################
#
# LDD
#
##############################################################


LDD_VERSION = cedfe6aa79955202a73e2786766bc504cc298c78
# Note: Be sure to reference the *ssh* repository URL here (not https) to work properly
# with ssh keys and the automated build/test system.
# Your site should start with git@github.com:
LDD_SITE = git@github.com:cu-ecen-aeld/assignment-7-zakimadaoui.git
LDD_SITE_METHOD = git
LDD_GIT_SUBMODULES = YES

LDD_MODULE_SUBDIRS = scull
LDD_MODULE_SUBDIRS += misc-modules

$(eval $(kernel-module))
$(eval $(generic-package))
