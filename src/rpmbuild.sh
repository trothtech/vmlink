#!/bin/sh
#
#         Name: rpmbuild.sh (shell script)
#               build an RPM from the "spec file"
#         Date: 2024-02-23 (Fri), 2024-10-30 (Wed)
#
#
#
#
#

# run from the resident directory
cd `dirname "$0"`

# establish certain variables
APPLID=vmlink           # argument $1 but hard coded here
VERSION="$2"            # this varies so take it from makefile/args
if [ -z "$VERSION" ] ; then echo "missing VERSION - you're doing it wrong, drive this from 'make'" ; exit 1 ; fi
STAGING=`pwd`/rpmbuild.d

if [ ! -s .rpmseq ] ; then echo "1" > .rpmseq ; fi
RELEASE=`cat .rpmseq`

UNAMEM=`uname -m | sed 's#^i.86$#i386#' | sed 's#^armv.l$#arm#'`

# create the "sed file"
rm -f vmlink.rpm.sed
echo "s#%SPEC_PREFIX%#$PREFIX#g" >> vmlink.rpm.sed
echo "s#%SPEC_APPLID%#$APPLID#g" >> vmlink.rpm.sed
echo "s#%SPEC_VERSION%#$VERSION#g" >> vmlink.rpm.sed
echo "s#%SPEC_RELEASE%#$RELEASE#g" >> vmlink.rpm.sed
echo "s#%SPEC_UNAMEM%#$UNAMEM#g" >> vmlink.rpm.sed
echo "s#%SPEC_STAGING%#$STAGING#g" >> vmlink.rpm.sed

# process the skeletal spec file into a usable spec file
sed -f vmlink.rpm.sed < vmlink.spec.in > vmlink.spec
RC=$? ; if [ $RC -ne 0 ] ; then exit $RC ; fi
rm vmlink.rpm.sed

#
# clean up from any prior run
make clean 1> /dev/null 2> /dev/null
rm -rf $STAGING
#find . -print | grep ';' | xargs -r rm

#
# now try an install
# override the PREFIX for the install step
make PREFIX=$STAGING install
RC=$? ; if [ $RC -ne 0 ] ; then exit $RC ; fi

#
# build the RPM file (and keep a log of the process)
rm -f vmlink.rpm.log
rpmbuild -bb --nodeps vmlink.spec | tee vmlink.rpm.log
RC=$? ; if [ $RC -ne 0 ] ; then exit $RC ; fi
rm vmlink.spec

#
# recover the RPM file
cp -p $HOME/rpmbuild/RPMS/$UNAMEM/$APPLID-$VERSION-$RELEASE.$UNAMEM.rpm .
#                          UNAMEM  APPLID- VERSION- RELEASE. UNAMEM

#
# remove temporary build directory
rm -rf $STAGING                                                        #

# increment the sequence number for the next build
expr $RELEASE + 1 > .rpmseq

exit


#######################################################
#!/bin/sh
#
#
#



# I wish the following two were not hard-coded





export UNAMEM RELEASE STAGING

#
# process the skeletal spec file into a usable spec file
rm -f vmlink.spec
# no no # make STAGING=$STAGING UNAMEM=$UNAMEM RELEASE=$RELEASE vmlink.spec
RC=$? ; if [ $RC -ne 0 ] ; then exit $RC ; fi

#
# clean up from any prior run
make clean 1> /dev/null 2> /dev/null
rm -rf $STAGING                                                        #
#find . -print | grep ';' | xargs -r rm



#
# override the PREFIX for the install step                             #
make PREFIX=$STAGING install                                           #
RC=$? ; if [ $RC -ne 0 ] ; then exit $RC ; fi

#
# make it "properly rooted"
mkdir $STAGING/usr
mv $STAGING/bin $STAGING/sbin $STAGING/usr/.
RC=$? ; if [ $RC -ne 0 ] ; then exit $RC ; fi

#
# build the RPM file (and keep a log of the process)
rm -f vmlink.rpm.log
echo "+ rpmbuild -bb --nodeps vmlink.spec"
        rpmbuild -bb --nodeps vmlink.spec 2>&1 | tee vmlink.rpm.log
RC=$? ; if [ $RC -ne 0 ] ; then exit $RC ; fi
rm vmlink.spec

#
# recover the  resulting package file ... yay!
cp -p $HOME/rpmbuild/RPMS/$UNAMEM/$APPLID-$VERSION-$RELEASE.$UNAMEM.rpm .
#                          UNAMEM  APPLID- VERSION- RELEASE. UNAMEM
RC=$? ; if [ $RC -ne 0 ] ; then exit $RC ; fi
cp -p $APPLID-$VERSION-$RELEASE.$UNAMEM.rpm vmlink.rpm

#
# remove temporary build directory
rm -r $STAGING                                                         #

# increment the sequence number for the next build                     #
expr $RELEASE + 1 > .rpmseq                                            #

exit


