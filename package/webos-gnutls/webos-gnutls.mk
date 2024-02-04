################################################################################
#
# webos-gnutls
#
################################################################################

GNUTLS_VERSION_MAJOR = 3.3
GNUTLS_VERSION = $(GNUTLS_VERSION_MAJOR).30
GNUTLS_SOURCE = gnutls-$(GNUTLS_VERSION).tar.xz
GNUTLS_SITE = https://www.gnupg.org/ftp/gcrypt/gnutls/v$(GNUTLS_VERSION_MAJOR)
GNUTLS_LICENSE = LGPL-2.1+ (core library)
GNUTLS_LICENSE_FILES = COPYING.LESSER
GNUTLS_DEPENDENCIES = host-pkgconf nettle pcre
GNUTLS_CPE_ID_VENDOR = gnu
GNUTLS_CONF_OPTS = \
	--disable-doc \
	--disable-libdane \
	--disable-rpath \
	--disable-tests \
	--disable-guile \
	--enable-local-libopts \
	--with-libnettle-prefix=$(STAGING_DIR)/usr \
	--without-libdl-prefix \
	--without-libiconv-prefix \
	--without-libintl-prefix \
	--without-libnsl-prefix \
	--without-libpthread-prefix \
	--without-librt-prefix \
	--without-libz-prefix \
	--without-tpm
GNUTLS_CONF_ENV = gl_cv_socket_ipv6=yes \
	ac_cv_header_wchar_h=$(if $(BR2_USE_WCHAR),yes,no) \
	gt_cv_c_wchar_t=$(if $(BR2_USE_WCHAR),yes,no) \
	gt_cv_c_wint_t=$(if $(BR2_USE_WCHAR),yes,no) \
	gl_cv_func_gettimeofday_clobber=no
GNUTLS_INSTALL_STAGING = YES

# gnutls needs libregex, but pcre can be used too
# The check isn't cross-compile friendly
GNUTLS_CONF_ENV += libopts_cv_with_libregex=yes
GNUTLS_CONF_OPTS += \
	--with-regex-header=pcreposix.h \
	--with-libregex-cflags="`$(PKG_CONFIG_HOST_BINARY) libpcreposix --cflags`" \
	--with-libregex-libs="`$(PKG_CONFIG_HOST_BINARY) libpcreposix --libs`"

# Consider crywrap as part of tools because it needs WCHAR, and it's so too
ifeq ($(BR2_PACKAGE_GNUTLS_TOOLS),)
GNUTLS_CONF_OPTS += --disable-crywrap
endif

# libidn support for nommu must exclude the crywrap wrapper (uses fork)
GNUTLS_CONF_OPTS += $(if $(BR2_USE_MMU),,--disable-crywrap)

ifeq ($(BR2_PACKAGE_CRYPTODEV_LINUX),y)
GNUTLS_CONF_OPTS += --enable-cryptodev
GNUTLS_DEPENDENCIES += cryptodev-linux
endif

ifeq ($(BR2_PACKAGE_GNUTLS_OPENSSL),y)
GNUTLS_LICENSE += , GPL-3.0+ (gnutls-openssl library)
GNUTLS_LICENSE_FILES += COPYING
GNUTLS_CONF_OPTS += --enable-openssl-compatibility
else
GNUTLS_CONF_OPTS += --disable-openssl-compatibility
endif

ifeq ($(BR2_PACKAGE_P11_KIT),y)
GNUTLS_CONF_OPTS += --with-p11-kit
GNUTLS_DEPENDENCIES += p11-kit
else
GNUTLS_CONF_OPTS += --without-p11-kit
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
GNUTLS_CONF_OPTS += --with-zlib
GNUTLS_DEPENDENCIES += zlib
else
GNUTLS_CONF_OPTS += --without-zlib
endif

ifeq ($(BR2_PACKAGE_LIBTASN1),y)
GNUTLS_CONF_OPTS += --without-included-libtasn1
GNUTLS_DEPENDENCIES += libtasn1
endif

# Provide a default CA cert location
ifeq ($(BR2_PACKAGE_P11_KIT),y)
GNUTLS_CONF_OPTS += --with-default-trust-store-pkcs11=pkcs11:model=p11-kit-trust
else ifeq ($(BR2_PACKAGE_CA_CERTIFICATES),y)
GNUTLS_CONF_OPTS += --with-default-trust-store-file=/etc/ssl/certs/ca-certificates.crt
endif

# Some examples in doc/examples use wchar
define GNUTLS_DISABLE_DOCS
	$(SED) 's/ doc / /' $(@D)/Makefile.in
endef

define GNUTLS_DISABLE_TOOLS
	$(SED) 's/\$$(PROGRAMS)//' $(@D)/src/Makefile.in
	$(SED) 's/) install-exec-am/)/' $(@D)/src/Makefile.in
endef

GNUTLS_POST_PATCH_HOOKS += GNUTLS_DISABLE_DOCS
GNUTLS_POST_PATCH_HOOKS += $(if $(BR2_PACKAGE_GNUTLS_TOOLS),,GNUTLS_DISABLE_TOOLS)

$(eval $(autotools-package))
