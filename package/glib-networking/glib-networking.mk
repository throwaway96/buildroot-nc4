################################################################################
#
# glib-networking
#
################################################################################

GLIB_NETWORKING_VERSION_MAJOR = 2.70
GLIB_NETWORKING_VERSION = $(GLIB_NETWORKING_VERSION_MAJOR).1
GLIB_NETWORKING_SITE = http://ftp.gnome.org/pub/gnome/sources/glib-networking/$(GLIB_NETWORKING_VERSION_MAJOR)
GLIB_NETWORKING_SOURCE = glib-networking-$(GLIB_NETWORKING_VERSION).tar.xz
GLIB_NETWORKING_INSTALL_STAGING = YES
GLIB_NETWORKING_DEPENDENCIES = \
	$(TARGET_NLS_DEPENDENCIES) \
	host-pkgconf \
	libglib2

GLIB_NETWORKING_CONF_OPTS = \
	-Dlibproxy=disabled \
	-Dgnome_proxy=disabled

GLIB_NETWORKING_LICENSE = LGPL-2.0+
GLIB_NETWORKING_LICENSE_FILES = COPYING
GLIB_NETWORKING_CPE_ID_VENDOR = gnome

ifeq ($(BR2_PACKAGE_GNUTLS),y)
GLIB_NETWORKING_DEPENDENCIES += $(if $(BR2_PACKAGE_WEBOS_GNUTLS),webos-gnutls,gnutls)
GLIB_NETWORKING_CONF_OPTS += -Dgnutls=enabled
else
GLIB_NETWORKING_CONF_OPTS += -Dgnutls=disabled
endif

ifeq ($(BR2_PACKAGE_LIBOPENSSL),y)
GLIB_NETWORKING_DEPENDENCIES += openssl
GLIB_NETWORKING_CONF_OPTS += -Dopenssl=enabled
else
GLIB_NETWORKING_CONF_OPTS += -Dopenssl=disabled
endif

$(eval $(meson-package))
