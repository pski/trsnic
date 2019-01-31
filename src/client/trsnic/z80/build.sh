ZMAC_PATH=~/Development/trs80/zmac
rm -fr build
mkdir build
cp *.asm *.s build
cd build
$ZMAC_PATH/zmac --rel --mras trsnic.s
$ZMAC_PATH/zmac --rel --mras nistnonb.asm
$ZMAC_PATH/ld80 -E START -o ./nistnonb.cmd -P 5200 ./zout/trsnic.rel ./zout/nistnonb.rel
$ZMAC_PATH/zmac --rel --mras nistblok.asm
$ZMAC_PATH/ld80 -E START -o ./nistblok.cmd -P 5200 ./zout/trsnic.rel ./zout/nistblok.rel
cd ..