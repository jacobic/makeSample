#!/bin/sh

# ds52
# screen -r AGN_SPIDERS

# input catalog
CAT_IN=/data44s/eroAGN_WG_DATA/DATA/photometry/catalogs/XMM/XMMSL2_AllWISE_catalog_paper_2017JUN09.fits.gz

# spectroscopic catalogs
CAT_SPEC_v5_11_0=/data44s/eroAGN_WG_DATA/DATA/spectroscopy/catalogs/SDSS/v5_11_0/spAll-v5_11_0.fits
CAT_SPEC_26=/data44s/eroAGN_WG_DATA/DATA/spectroscopy/catalogs/SDSS/26/specObj-SDSS-dr14.fits
VV_CAT=/data44s/eroAGN_WG_DATA/DATA/spectroscopy/catalogs/veron-veron-13th-ed.fits
CAT_SPEC_2QZ=/data44s/eroAGN_WG_DATA/DATA/spectroscopy/catalogs/2QZ/2QZ.fits

# output catalog names
CAT_TMP=/data36s/comparat/AGN_clustering/catalogs/xmm_tmp.fits 
CAT_OUT=/data36s/comparat/AGN_clustering/catalogs/xmm_tmp2.fits  
CAT_SPEC_0=/data36s/comparat/AGN_clustering/catalogs/xmm_tmp3.fits 

# final output name
CAT_SPEC=/data36s/comparat/AGN_clustering/catalogs/XMMSL2_AllWISE_catalog_paper_2017JUN09_v5_11_0_sdss_26_VERON_2QZ.fits 

# masking the final catalog
CAT_SPEC_MASKED=/data36s/comparat/AGN_clustering/catalogs/XMMSL2_AllWISE_catalog_paper_2017JUN09_v5_11_0_sdss_26_VERON_MASKED.fits 

#Masks
MASK_2RXS=/data44s/eroAGN_WG_DATA/DATA/masks/2RXS_HPX_nside4096_all_ratelimit.fits
MASK_XMMSL=/data44s/eroAGN_WG_DATA/DATA/masks/XMMSL_Map_withflags.fits

stilts tmatch2 \
in1=$CAT_IN ifmt1=fits \
in2=$CAT_SPEC_v5_11_0 ifmt2=fits \
matcher=sky params="1" join=all1 find=best \
values1="ALLW_RA ALLW_DEC" values2="PLUG_RA PLUG_DEC" \
suffix1="" suffix2="_BOSS_v5_11_0" \
ocmd='addcol hp3 "healpixNestIndex( 3, ALLW_RA, ALLW_DEC )"' \
ocmd='addcol hp4 "healpixNestIndex( 4, ALLW_RA, ALLW_DEC )"' \
ocmd='addcol hp5 "healpixNestIndex( 5, ALLW_RA, ALLW_DEC )"' \
ocmd='addcol hp6 "healpixNestIndex( 6, ALLW_RA, ALLW_DEC )"' \
ocmd='addcol hp12 "healpixNestIndex( 12, ALLW_RA, ALLW_DEC )"' \
ocmd='addcol in_BOSS_v5_11_0 "Separation>=0"' \
ocmd='delcols "Separation"' \
omode=out ofmt=fits out=$CAT_TMP

stilts tmatch2 \
in1=$CAT_TMP ifmt1=fits \
in2=$CAT_SPEC_26 ifmt2=fits \
matcher=sky params="1.5" join=all1 find=best \
values1="ALLW_RA ALLW_DEC" values2="PLUG_RA PLUG_DEC" \
suffix1="" suffix2="_SDSS_26" \
ocmd='addcol in_SDSS_26 "Separation>=0"' \
ocmd='delcols "Separation"' \
omode=out ofmt=fits out=$CAT_OUT

stilts tmatch2 \
in1=$CAT_OUT ifmt1=fits \
in2=$VV_CAT ifmt2=fits \
icmd2='delcols "_RAJ2000 _DEJ2000 Name n_RAJ2000 FC"' \
matcher=sky params="2" join=all1 find=best \
values1="ALLW_RA ALLW_DEC" values2="RAJ2000 DEJ2000" \
suffix1="" suffix2="_VV_ed13" \
ocmd='addcol in_veron "Separation>=0"' \
ocmd='delcols "Separation"' \
out=$CAT_SPEC_0

stilts tmatch2 \
in1=$CAT_OUT ifmt1=fits \
in2=$CAT_SPEC_2QZ ifmt2=fits \
matcher=sky params="2" join=all1 find=best \
values1="ALLW_RA ALLW_DEC" values2="RAJ2000 DEJ2000" \
suffix1="" suffix2="_2QZ" \
ocmd='addcol in_2QZ "Separation>=0"' \
ocmd='delcols "Separation"' \
out=$CAT_SPEC

rm $CAT_TMP
rm $CAT_OUT
rm $CAT_SPEC_0

stilts tmatch2 \
in1=$CAT_SPEC ifmt1=fits \
in2=$MASK_XMMSL ifmt2=fits \
matcher=exact join=all1 find=best \
values1="hp12" values2='$0' \
omode=out out=$CAT_SPEC_MASKED

