ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.13.1
docker tag hyperledger/composer-playground:0.13.1 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� 02�Y �=�r�Hv��d3A�IJ��&��;ckl� �����*Z"%^$Y���&�$!�hR��[�����7�y�w���x/�%�3c��l�>};�n�>԰�DV@ŭ6�Q�m�^�®�{-����@ ���pL��S�B�������H�R,����BpmZ <r,����x˞�J��,[��6x&=�8Y]E�6���M>�o�uYL�B�ç�ނuR�赑e ������K1�6��#	@ <���m��+CfG���B�3@J���҇�A!��n�� \?Q�Uhi6��N����5�@�2�a�SB�ė�\2��	��"d)ZK7��iaà+#�B�X8��өE�H%��4��ݤ1ـ��w.���O��i�7L�:d�-\��x�M�FV-]]4|٪��oA�����:bPXD�!U��:�"�&�C��`�����l
�,�FVQ����]���K�9,�!����5�?�CZ�eЮ׭��
�������#؎	a��S��g��P=���&jP��V�n�R�΁U���E��b�e8����&�Wa��㗗�Ȁ?gԟ?usd�l�{Z_}t����ǖ�Rf�t�i�a�R2��N����60]ø��Q�s&r��j2���t�z�Y&4�d�v}�q��m�?x8��N�§�{o�:y�Xd��Ga���B����(K�@��{2�p�o��;��Q�kz�5h7��[����%��$,K�(����Rt����|��f�
�gc�R��>���i�E5&�|�Pʻ�G�d���σM|�=hw5�)����8�Y�`]�k��Oe�.�g�QZ��*`-�_6̐�6T�����66�v�'�=�%!2%�ѵ�_�M�p�{��r�D��B0�N� ��,Pfe6p0�3�9G6��-�W� ��q;m�]����vۖށ�c��Y�<�l���������� �lhɓ�[�����3Jc�����)��4�5}��kx�3t�6k[!R�@�?���IdG��v��XÃ^V�6����66\:�6��{���$�aUg�W�z�o��������;���F�=�A��C����h�d!R��J�O�`<88O`�����=����{D��z2�Cj�AT��M���?�0R���]]�%��D�N�Iy��W���P/�\�����@Sj�"�X�i�f}�R�憕l��orWw(�<}�1m>nrz����H<��v σ��(I���60��H{�6$�^o��{�G"���X?e���ƥ���x����Kt���oҬ�� �h�}:�����Yco�l m�E��p�<6g��N��?L���{�uX�=�G C�1�'�ccxؙ�&v�9�YV����>n�>U��a��	�_]��>�9��v�>�X�6�O.L�]�a�h�5L>���(�;,�w�CAHu@�����g~<�}�w�3��6و�g��?�<m���|B=�&]6��۟�����F�6�������d��
���`�ի�T�CDoj^]���F�Ѕ���Ȇ*�a�-�
3�?e�{;��p��h$&���*`}��e����=��D�EY�M˿�>�]x~Rjt�yg��;�!��1��Qw���Qo7k��礹�E)�A�l��T���	ꄫ�����R�3�Mȯ&�?��]��<{z5��F�Ĝ��%�r3J��K~8N�ʹ����m���	���5m�$N���h^�����k`�U�!�F�i�t+����#�Y�S���rE)U>Tr���Qe~�'�f�]���6"��ٛ׆0Q{G�xc�~��v������E�~޾Og6��g��B��{0ܒ0�rnW�A����n��,���􊹥@�u�,��N ��J���_��*�?.��lAP�I.�#6C��d���NΏ軋5���'	����X�_6���A˹��2��´����
���|����l��n�1�-T�/�������}�u�3��_�{��ߏ����:�s�|���N\p���o������%(x���O�8]�������4݅c���-�Ȳ���-�t���45;��x u��G}���N�'�B�RJ����2�h����(���D�l��:���}��%=��O����AF���!߉^dd�~J���J�bA�6UB/�z/�Ign�L�H�;�N��*4h����'V����=��:�
�M�/�����L臱�Xt��5&^+����S6��;�S�t�O����@54�.�on����������p��k���pw���#՚+����"����K!��B�xz-�h��8P����mf bP���Ux+l���T��ު��:Qe���T���L�#rtJ��Hx-�+�_���G��2��z��a'�� ��S|�k���_��tS���K����i��c�u��J��� ������vg��~H���V@���=dt��`,�j��@{UNm�P �48���$ �Y�hh�ڜ��nU����G�>Ȁo8k�'�7u�f<[��%W�%0����l;^�?��4�O�1��c��̿�	}�f��H�Ȱ1�hf按֧�e�J�1Qa,��P��<��=ȧ�3�,ϟ2/W�X�>,<���Q2��.x4�ML!2}�Ԇg%�nl�W3�������<���4�'�q��1&����U�����<�t.��Ax��_!�>��D�u��J�������o����������5�S�營P�*��,ŷj���r֪5Y݊ǣ�j\��D�����ò
�x$����T݊D6��k�/_sӄ7����Ni���/���6�������G�>�$6ml9������6lT��}��&���W�|5�����Y�;{�_6����mp���H��}"8sb�ͫeo�a�1A��a�8N	�h�1�`����f}��+����y��j���?,���j���n�&m,��������:��J���c�'�[]#eÝ� )�I���5�С���'O��6�,巯x[��s���8=�"�2�UŢ՚�ƶ��Vm+�j�\�R�F�'�[԰,�P܊�xU�A����&�!�+^ED�֨��	PH���H�K�\&�T*iV����r��y2��ɺ��%�z����𢧅�~�q�i���in��.υ4�����}BAif�(�h�������RJ�ǄT%�,4�Y�U�v�I�"s�y��J�<��w��ʸ��qy*m]d+�W��x��2ힽi4�o�Y9r^���ݔ=�|%-����L��nC-�+j�p���pP�I'�윕	��w��y��/��d�4u\,f����G��J�L]2��+J��u�V�}ZI��Eo���;�Hʸ��Y��$r�Ϋ��Z>!0��=)��xQ�\��r�@ٌ�f/��V�S�$��L&��D�c����J=�M&�����"�D��ڻH�l�\���N��F?�;9�8����R�ub��o�ǌ�Q��){��u=��������V���y��=�ӽl��w^�$��Lւ�VKuӉP�H�x��R�t�wK��R�J+犒O�tTZ�[l�{J.ѲΠK��w�U�ov�Z�-"9xp`	�L4�K�#���ݼ��##+�T���O%sŤl����d���Z9E���GN⡆y�"��EP�<9��;I-T��ˑ�(n^�4���6L��x�-�3��w����r<��
G%e��X>]H����C��O�ج��f�t̘�g�~� z�!��� �Q!��?P&`��-��Ex˞�J���]uw�����c_Ê���?<��',��u��J`�O:,厉q {�SV���粻�&+�lt"+t!���ź ����=���z�}̝(�BY|�
����R/K{ESr��J*J��$��Q���5/30{qy,��~QE�ǜ|�<�K�^$c�������Ɖy��[9��U%�:r{��݊�Z(�o�|�17�|���g����/_�����_|6��V?�����a��Y���s%0n�������4������T�ã��RTSź�����Τ�`%�:qRwC��^���~���Y&�L#�-��q�3�xc�Ž���c:-S9���޽�m�^���R��7��=�ܳ�ہO��^��4���׃=x�_	["�����y��q5�$q�g���\"O�Y� P�h�J����(��ԛ����6����tdm�Q�[�G���E Xu��B5��Y��Ѩ.h��@�-h�:�~�G-k���}vi�?��e�8��7� ���~g� )܂����X�}�M)��6R�*����EPE�$�j� 0�`��zú2�1�]l;�/��s��<�F�=z�P�[�y��N�>4�>�#���8Z��23�"V�� ����C�j��hd"g=�Z>=�P��  y��ڠK/0v��r)�"PAd���^z��Q��a���в`�6HI�KG6��&6`T֣m�:�Au�Sah��=��8 ���GW'ۋMPi0�_ؠ(�K`C����E��I�9æ���ʀ�&�5P^5�Mh;�AL|K�U=C��@�&d|�����^z��Oޞ����_]��������>������J�5����v���,�b��c�����P""��X�nSF� �|0�Ӷӫ_Ø��-oQ��Iɜ�_o(�+Np�Ŏ�c����æ�>�2�T�e�U�3�KUh�)�|8�2����/ĵ��ѽ�I"R�ha���]���� Dئa�,r�������K��q��՛���7��j	T�$�k:q�v��%Ư7�K�K/S�!���9���һ�M���צ�.��2����9}��>i��&�rUǣOE��`�7�"X�D����];��!��T��:.��TTõ�]1�`��i��|��e����z�BuJ���U4�M4:!Z�dU�nW�c�W�a��G:��ʄ�޲m{�<�Ӿ"Â���vȒ����c�.S�O0?��`�td���Eߟ���R�
���g6�@�1�4&a(�����-�Dz�o��B�A�#&�X�����%�q,-w�4������3�j���ʏ�Nr��ڎ�Ĺq�Γŕ;��qc'N�@�!�@K �7�݌`��,�° 6#�7���k�9~�y�wUn��i��{��>�����p���Sq���%!�C�/��Y��K���_Q�����_�ǿ���|�/��Ǒ�q�{8�@~����?z���+�6�u]L�򧟅�P4$+&�Cr��(�b���c
ERX��p+F�
�q� �R4F�!��h>��_��/�<���D?��}��s3�����3��|������W(Z=������.�m��|�=���=�χ�ׄR>�o_>��C�|[��ނ<�.� �X�Ŕ��+��f����-K)��+�K�2��y������1K��Bn�r�U�]���]�+v������l�\�7Evg����ͳK�z���+�B�!Y�����R�<���6�.�ZE����C�9s�֫�qc[4ZW(��ߥ8�!�;�a��d�-";�}3a��ܜ��ߚg�p����dyZ'b�P4�d�an���K���8�F������c~y�^09s�E3��5H���c�_�._fǚ�)�ȥ�b��D��D";+���LI˔���Jٶ��Lt����B
ehk�;Ɂ@G!b,m͏@ד� �&k�̢��l� z���rVs|��IJ�vѹN�0��H�K���&��(L�
|m��ԇ�vw|��(�E��"�w�I��=��K\G0�y,���c5S�&ǝq8��-��<�L;q>Y�Ze��f�R�(��a���������)?VD)��hE/����-vy��Wr�]���]���]���]���]q��]a��]Q��]A��]1��]!��]��.��%�����YJ�D�-���p%��X�v�=���j"^�1�%Ne�L+Ƈ�m�C܋�YQ�\������.��T�֪��v�'j���{�yk�n�~W�Ժ�e���b2�����9n�ِ�FU���-�Y�Ū)�/7eB'�Z�V�L��T8Q���ɱ|m���9��d��Z� ������4Ft�8N����\v���]�r�[�x+"�����O�N�±�L�D�R�A��fNgʬ�֫��� CF:���8O�2z�j�T�P�dR�F97i�k�R��n��(5�.�2���]��v��^|8
�e����k������+��nx]��{o�z%�b�!���[pq�ɷ6������O�}-p������u�נNM�x��޸�#�/o���u�b�?� �>
|���~�}�
���~���0����?x���JQ�YZ�L�V:�7�����L��.�\�X��vkK�K���	�.�:?Nl�}�L؂��L�<�\�m�f�R���Bnc5�%b����u�e��&0eW���[(0Q�"-2���,xf�8�1�R�R��,�D*2��T���D��Ĩ|�:;�c<�`|��:VX���v[4��>N�Ƽ��h����ʏӕ5��H�l)�:�e��J$�ZN���9�;��y�=��4�)T�CZ��NAe�����юJ����x�81���ܒ@�[O�F�*���K�YS��l�f�Vi��,��Z�����`P�1Q�E��Zβ :�D��_6[�e�t�fNcz�m�h�*ݰ�7f�L���h��:Y�n�2{��o]�4q`(7=C�PO�<_�i&�E39�3��[����Y`xW�g6�Ē��2;�v]��x\ńk�ȅ�����E��/���z���X�Y�q�ݑ������{t��e�%�ͪ6-$����r�-{����Dޘu$-����.N��[KJ6���j�<V��D�#L1��8h�pksu^���0��{}����R�<�8}�
Wh�6mC���@���,=&^0�ݩ�9��a��H�g�==�T��֞Nhu�)��N<��Tuɪ�X໴ MO[�h^I6*J:U�ey̥K�YaBm�H��K͋E�b�+���T�ݏ�T�����pa\)���i�1^ G�����F6�_^�Y(��J��٠0���T�cLF�J!a�*1��~��LҎ"�'\�QCn{#$M�L�����Y���*�ڎ�ʤ�yW� �=��
���
�J�4>>�)���<y�U\l�%�����t�JDg�B����X�F�J�,J2F�RZ�<�t�!m��T$��N�F��BA\��C�Dʙ�x:f
�å))xQ��Nz��
�qO!�-v�����7$��P��QKQ��d�9��\�����b�<= a� |T:�v��ZF%�,���T4M���Fa�58�k��hUc���˘ɳKC+��W߲l�G>����;~��+Dxv��˄V&�y6�/![����D����܌�~�Yp����..�J�A�-�M}���,���a$��-�K%�^��#�������?zy���󈶣����7�7��g�O��3�FE�T��!q/��&q�W
o�>F�$�����Ȫ�; �=�Lo�O����`%Cr
��'��N���Z��^vy�,-�E�=@!:�'��t���½Ƚ�����!�%������Aa���F���?�C����>����m��N��`�q=���$Ȫ���N�!�\/w:a4��������|���:L�UIzp,M��b@w�#7�8��� x#4����H?��=?}��Mڟ�ݯ�A��z �w�s��y�ڨ
}-CΏ.]/������{��̺^d�c�v�W��� 9�*ms��';����\@���[O��їE�%t����E?�9@H����aI:�Q ��FL�͢���,n ��	@���݅��Rߘf��76i�,��T�.��Y�K'� o��h����b�,0( �r�S!��S{��SÕ�e��
��U#���	g�Ɠ��;X⣠C?�����s���L��� 6�zkkݧ�]E�U�3u2�߽2k�}�9_m<D�� k���I+��Y�
+��
�OV���V(���c��:Csk�^#k��UfWu\�4�������Y��@�;d� ��,0�Lƅ�^t<ɭ� ��u�Rǒv,��N`�"�Z��J.'�/�^H���b����o"l�?�����;�4luGp�`C�~���
�߮�M�.~]����W5�$���C_��u�VO�����@t:�T��K�^o��΂;�� ��}�œЀ9���V�� >������
'?HJ����i..���Е����Ë0�t�-9����.��FX���AI�\ɚ(D�����mlK���w��8l��A�DW �J���2v1�3I���VI��K<����}�ݗlةӄ��b��m�W��$x����.<�:�v�@yB�c=�4%D8h�\�6P�R�	��z�g!'AB_�� ;�w�7����0@�r$����akE���3;���`:�ՀU�X��� ����P�Is�6���[���<O-��e�5��\�Ϸ�m�\���ȴ��~d�2Q%�����cOW"�i�j�i8
��wyh}��-�{/^x�����2�&���a)N[����j��wZ�Ht�P-��շV�Z��b�����'��Ό�>9��LF}��k���	6����0|�긲�}es"w��A>��Gƺmⶵ!�q"��sNbX�XI
��<�4r�8��nI`M��P*Љ 
��b��]W�a��h�w�ƺ�������ɧ8���;��ǻv�/k��c���������!n�l���d�،�I�"���o	�8d�O�O��ڲ��17lY	���\# �����Y'h���������U���:�&w,q�
W�ei���E>���x��3�h|�k]��	p8�t�\��)W�Y;A�R;DRMB��d$F(RBd��ڭ����H�$����r��l�()�*AIgz�d@��.�?V�0+��ǲJ��'��'���-����S0T3�ڣر ބ�u���ͪ�cR�"�f����XD�d�P�-L�I�DQ���TT	IM���B�LFcJ8��%)���4��?'���>�?��1�춁⛮����-	=��h�%p����vQ��q׾`g����]1/d�\��U'�,W�3g�\2�U��3YiN;g�K"��Y�ȕJ�0h]a����������_�u7{�'�\X�dPq:#��<��w<vUn�j�}�u�sP��֎�L�3�hl��8WC�I��Fwڄ���V�L�:����`�h�w�M��d�N�Z�۹a��t&`����Z�}@���/9L��䷢|^H��\�D��ɳ<�7���h>ϱ��6O�SN�g�g\������l:T�'(��{��L����б���~��%A�gE^zz���r��	��6����V�T�$�s��<�rb5W<��=s���iw��5ֱ$�3YO������a�YV���I�lI�E����"��%�Y�<e�K��s�x�e�19��FL%c��eP�o��G��'���;��ڒ�+�0��H �:vS{Dt�NSw��kh>x6��&�ݜ��ηl�1�-V�+X��������>�<j��9$��K�����rq�+$���"��e��Ō��f�<P(����f[ǻ��^�ɻY��0�E�_�����<�����2߉���#���ߒѷY��뿏�J��&�m������>���C�[�m��>���
��^ҫ �	۔�d$|���H�����ş�{��i_����8������������������Y�F镰�����^Ҿ�?E�I�.��`Q��ʸ%;�8&7�!���R+��-��b�v�"#�f$U����aBj��/�:���U���(|��;���K���a2o��l�ԡ�GZ��Α��>GSB���:ͅ�u]��+3Nr�*	T@ϩv�k�H�K�g�R���5�lq�?�F�j���"n��e}���O'�t�7�T�����WBXL��$u�Q��8���/���ӫ������^����!�=�Cڝ����9�ǩ���>ҫ �	l��� ����%�/������ �����������>�=��Ծ�)�J���?��{��xd���`��%��^�@��)���A������ږ��A��#�Z�����_ڗ���&�-�O�{�֥&�u����1Z3��MEE�/g "���Z��hw%��N�|��JU��5�ZsS���pT'�	Gu��G8H�?���'�T�_�C�_�������<� �W���Ck 
�?C<����[	ު��[�m>�*ݠ��y�qXw�N��K���?�Z�?CCJ����m������c��1޽�y[��޷�Y�דYL=�o�����,�`��¯VyC+��E��z�E���U�9�n��:Q̅�*�:_G���Z�a��
�E�j�'����=t��72������'�={�m���q�wȃztĝ��`^�))͞,m�^z��j��v���}ʗ���v�i꫱q���f�F�s�}#�h9��ʴ�{�X�ړu�2���a(���x������e��b���G����L$���k��eA,�z �����������R������'������O���O���O�	��
 ���$���� ����������_����H���o����B��������Z�_��L:�bz�,���:�n�����V�����u�����ƣ�!�}Y����:n�5�i@��`��CymĻ�`���H�i�ޣ���eB���FA�4I�B.���:cvN���>���no��ij�R�c��#����^}�	�Q,�ג~)�V���_��ؽ���m|�����u:!;%���;�ewŒ�HI��t�2��^2)�l�5���b"��3�ǋФ%i�_���	��V`�|�	��c�td�6���/��߀��#��?�_@@���K~H���5 ���[�����W�/��W��6.�3�,�Yb��L@��B���|R,�\HRA�S!2�@x�����Y�?����g���e�ӗ�DJ�V�d�<��Ӿ��Fԩ�,[�dm�S����3{{���S�.�#�Tݽ�ّ��66]���jrX�p�.6[J�=��y�&������� k�L�>�ó��:����@���������a]�Z���������Om@��_��2���7
��_}����ѴT稫��vs����3�uW��n���;����S{�WGr<h&�o^r�+df��Ses��;	e����*ƇqN��TqGv�.����p��`�<�-U�u���߷��?	�oM@�����_��7 ��/������_���_�������X�����(�_xK�y�U�����ALڲ�G�̈́�BM���!���%��g����v�cW����3 ��� ��z�� W��G�p)>U����7� ��<���.6�CJ�e�%W���ϱA�Ք�n��Zۥm+ö\�d#6���ODu�����^>�wUo�~)���f{a�Ş�Dߍ�OO����|�� �ے
C��{)V[�U|b��蓾�i�� 2ۧ��<Q��H*7X��9�Sv?7iW�9~�@���!5��VZ{�x~�I�&���x�@(�%k�H���1k5�ٱ[�Rc:�;R�L���b);��Ft�/�=1���Ќ��\d�ׇMjt��ag��">K&�_VNW��E�P��D�Ѡ������C&<�E�����8��p�T��ğ�`��T����,��������������������_o���5��G~�2~8���̟dD��/��ϲ�q8�����i>E�3^�h."|֏`��ÀB��l���O%���^?8�J-s��f�9$�$9��Y1za�Ftɚ�ZL�i��*�$���ŶKzi�[����]�?5�!��PR?K6�~��Iua�7�ˈ�E�^K�:g�ǎẤ��e��Zξ�S���~+P���������������%��P�����R��U 	�g������?�$��"��������U����P9���/�����*����w���
���~�����o��ߎ��e֔ڗt�%��Z[��aY���"���o�4؏�~��~d������q��(��xx�ǌ��S-y؛���#��%�h�ζc��މ3'�T/��,����J�mo5q�;��������$��y��
oڜ�����h�Ҏ}�8R��6v��*�Y�kۉ�o�6{�?r�&	�~�[�f�m�(��~��-�H�.ӡ}��8����ʚ%ӹn���ƻ��F4�3����������-F�I�5c-��M7f�2K[����Vw�����|<�ȴ��f�;�ˮ(迫ڃ�kB5��wGP�����'	
�_kB���������7KA�_%��o����o����?迏��u ������(�?���C����%� � ���I�/EC�_ ��!�����?���A�U��������y��������������$�?����������m�n �����p�w]���!�f �����ē���� ��p���_;�3O����J��C8Dը���7�����J ��� ������x�a��" ��`3�F@��{�?$��y�� ���?��� ��g�4�?T�����������I�A8D������H�?��kZ��U���I��� � �� ����������J���˓��������C��_��8�� ��0�_9P��a��>��?���������! ���'�� �W����}������(�?��{��(�?A\�`�G���)���B4����+I����C��C��9_������G��]���K@�_�T����Z�GW����ݹV��?U�R/��7`Y1�kE�'�i��U�b^_�61���x�>�[J�C�ڒ��P4eQ�Orn��03�U��e�Q�荼NAc�h�^�!saZ�qG����b�u����Ɉ�C����KO�8x��$c�����I���#����Yj������(�����H�?��������q-�~1~C���P�Շ�Y�B�`΍C�)Z���a�Foɝ�`V���"��E�ԭ���s���>�k�l���C��m����5�,p�<f�Gg���vMwz����].�ٹ-�;C�)2kFN��Q�m���ʘP�}+и�?���oE@�����_��7 ��/������_���_�������X����3�����-����k�R7Q�X޳[{b��/�V���V���߫��I;E�$�Md��ľ%��z�~�9a���V���4b�C��L	v�D��ph�'�݋�,>��c}�.Ų<�9���%��lF�����fn��{�v���+}��{�t�m��r[RaH���^�Ֆt�߉K���\蓾�i�� 2ۧ��<Q��H*7���9�Sv?7iW��B�P-Y�p���	����D0�T�ϴ��<��͹w����(4ڽ�����'3��
=?ՈY�Z3A$�8�L�Ft�Q��|�1���ﯻ+�����g���[�׿����8GB��|�����������p�� 
�A?�����J�џ��D7�BU\���'8��*���8�������@5����	��*�����k���I��*��g:�,�._�?󴱲�$�!H��§��\(?;�����=�C&�n��E��qS�?��+]c�=��h/���s?����
5���-_[��!�w�rx�.o��-��sl��)?9����u5$�����-e��P��Fή큊}=ި�^m�L�sq>&��g�ZL�e��-
��l2ҡG���u�ѢM�K�xJ0�\�S�/&��m��/Vދ��O������R<Uo_��8��~��7;ׇ�NӐ_�3%�I�8�7uvTC�v۲�#b�o+�i,#�*{l��F���e�͎�H��H䢗ؼD�t����`f���9�d"��i��k����n�Z,%nӗ
�<ŏ�&(�=��ԦB�/��c��+����~w �����?��V�j�0x��ps��I_�S!�_��P��4���|r4%�}�ؐ	�(?�Cb������������J�3��6���p�I�pL�f��(���1�v�h��������\��Z��#Wnj�����������0�_@A�������|���CU\�7�?�q���W	���z�����ځ?��<���b��p������;��a��4P�̋�w3ذ�y���~؏x7���obH�����}���}��gQ���XRI�:ܑ��nC�Qkia;��'}&l����`�i$|�%�"dEyDa����٣Ŝ���ɦՍ-�n��^��n�aO|??P�M"��8�y�!�w���N���E���t1��u��'&��L��,��fD�N4��դ-Qb�	�V�Y�E��ןj�u��2'�i-�u��N��X[v�f�k���h�b���~w����g�?��[	*��3>�a��<�Ss�$o���~�pQ4�'|����߄W]0�	��I��>B������������������_��n�6-��v�i��gz��q�自h�Y9�$�����-7Ղ�W���������-���G���U��U�=�?�_�����v�G$��_7�C�W}���_c ���������?GB�_	���ȷ������ִ��4wc�^O�{�<>.����O�pI��?��>��U�������\�C��"��(�J��b.Ջ��.�:�>��>�|~�-�޽s���uu�\a/GW.���sR�����ܜԩs���Cz��V*�����[9��� uj��mw҉Τ3�f3q}���D��w���Zkӧ�kV���>^���Jxa/�<���i9�Bg\�D{[[w:�T��hV�n�l=����}s|��*&��h�6�2�rڶ�t��H�1k	\�m����J	/Sh
�y���y�G�)q�<��n�x�=���gw;�b�ꇽ��v~��6lIi6F�í2�%Ym^���'�u����vcR��ld���j0��U���UL,ZJ�Ѷ�f�~���#ؕS�벵��R��p�qT��J%)�H]�+����|ß&�um�o��Ʉ,�C�?�����_��BG�����#��e�'_���L��O����O������ު���!�\��m�y���GG����rF.����o����&@�7���ߠ����-����_���-������gH���!��_�������_��C��@�A������_��T�����v ������E����(��B�����3W��@�� '�u!���_����� �����]ra��W�!�#P�����o��˅�/�?@�GF�A�!#���/�?$��2�?@��� �`�쿬�?����o��˅���?2r��P���/�?$���� ������h�������L@i�����������\�?s���eB>���Q�����������K.�?���D���V�1������߶���/R�?�������)�$�?g5���<7׭2m2��ͭb�5M�dR�����d˘d��ɱ÷�uz��E������lx��wz�(q��Fu����u��
M�)�ǭ�o2��wY��^�պ(����t�6ǝ6&w�Ɋ~HS,��8�m��/k��Ȏ�d�)-zB:]=h�V�E�Gu:,�q;,����m����d�U��\OS���՛�nǮU#�rEy�'����$YG���Wd�W�����E�n𜑇���U��a�7���y���AJ�?�}��n��%��:~��'jv��w�^���b�Q�ˆ��m��m��E��Ξ����Fu�j�[��j���#��͆�6,E�D8��~],���ߪb۰�sUk��ɫ�v��]mN���&�P;z��%�����7�{#��/D.� ����_���_0���������.��������_����n�QP�C��zVa��U���?��W��p���)VĚ8�)__�_ف����6��h�@*���z�.K�l�?���E��5}4o����D�0.L�x\��!iͱS��ˉI�U'�N��z�����~Q�j�J)l�[m,���m
��:;���_e�*��і����D�Z�F�1M!��bwXO����h�IJ�}v~s��V�~������^�|Jb���*P���r��KQ]٨5�V���v9X��ͦ2⇃8?LKQUZ�X�8���N�Y2D{�����qqېI�]?hB����|/Ƀ�G�P�	o��?� �9%���[�����Y������Y���?�xY������������Y������&��n�����SW�`�'����E�Q��-���\��+���	y���=Y����L�?��x{��#�����K.�?���/������ ���m���X���X�	������_
�?2���4�C����D�}{:bG[U�7��q������0�Z�)�#fs?��
����s?���L�G����"�w��Ϲ�������uy�ݢ��]�D�����8�P�;fm���\����j�7��O�gCvfNcap���M#��8:�!,Y��dSSmG��Q����Ѽ��_�Jޯ�WOG���\�F��4��
�}8V�����tu���_����Ug"��`1�lF90'<���%ik��Nt��jX#9jSo�}2�V,�X���`�fa�w��ReCi��DpT���vra���?2��/G�����m��B�a�y��Ǘ0
�)�������`�?������_P������"���G�7	���m��B�Y�9��+{� �[������-��RI��_�T�c�Q_D��q��Hmك�d�S����>�ǲ�<<�����،��i
���=��)������0��ыFI�h���z~��T�i��,u��7CS��W�*G}���hA�F�P/rq{+��eY!F�o� `i�����$�����B�{�X�/t)E�W��|aʜ�b�-?
�¢��nkO�����lX޴��P�G&��^S:K�X�!m�WЭ	�m�������?L.�?���/P�+���G��	���m��A��ԕ��E��,ȏ�3e�7�"oY�fh�f΋�N[,�s�N��E�d�l��a�OZk�:ϙ�O�9�c�V���L�������?r��?�������O�H&O��Q�Q�Nf��j�j�4*���<�ބ&{�`��Vb�埈`g��kL^�J���������ʝJ]X��5rr�4׉Y<�ZV p�|��n4��?_K���������q�������\�?�� ��?-������&Ƀ����������z�X�􎬊Ĝ�*Ċ��K���[Q�Ew��/�N��>�\_:���`K��_a;�YRL=4�,�G�~u�N�����[�iW||Ռڲn0.O������&^����24��%��E��3��g����``��"���_���_���?`���y��X��"�e��S�ϖ>�����ct�\���t/B�����S�����X �������wں�E[M�$������q��tc����r�J̧2�"��rV�#��'�`�)��Byh�X��a���שҬ�ڶ��RW�/�<,��DM���';O|�V�OE�;�q:&�BwX��u� v-a��$:9�6�RIv��������my�(�+�*"c���=QJ��S�M��MԵ�_�S��i�򳽈}U8P��Hԫ+��u��ˆď䓻p��J��ڞ[���b�n�0Fb��*4��Â�S�}�1�Յި���|8ezTqZ&�r�w��#O�9��}tx]���'����B�i&��?�ݹm�x������:��_v��Gm�(�����	bO�>J5�cG�?��+�y����<�Y���t�Ϧ��|L������]$�=c��������{=���G�����CI�������5�L�X���R��7?�%�����?}J����p�}���?�㾊��i>�����������.0�ox��D����n���Ǎpm�N������{,4#���'縉�i$����I_�zR��v��I�d���r��x�0qcfr��${{��(����7�x�#����w��~�c�=�I��%���w�����w܏�ɫ���[~I��OO;v������<Q�T ���;�r��}u��������<��XK����~��`m�m3�Ϗy��ӕ�渆�޳�M��"�`纎k��DނO��?q'w&�� �Bo�q�4����ÿ�Z�~����f�?�i,<��/���צ�������{��$�|��9��f@�{�M�t����?n�q��W��œ,���67aF���x�s�pM�ӓU=���SJZ��E�qwɍ'�{Տ�j�����H�VM�;���Hva*�����t�w�j�ez�w�ח������=q�}                           p���0 � 