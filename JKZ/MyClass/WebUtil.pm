#********************************************
# * @desc        �����񑀍��ϊ����̂������A�h�`�F�b�N�⎞�Ԏ擾���̃c�[���Q
# * @desc        ���o�[�W������WebUtil�𗘗p���Ă�N���X(JKZHPEdit�Ȃ�)�����݂��邽�߃o�[�W�����A�b�v�ł͂Ȃ��A���W���[������ύX���đΉ�
# * @package    MyClass::WebUtil
# * @access     public
# * @author     RyoIwahase
# * @create    
# * @version    1.2
# * @update        2006/12/15 mbconvertZ2HKana��ǉ�
# * @update        2006/12/15 mbconvertH2ZKana��ǉ�
# * @update        2006/12/15 mbconvertZ2H��ǉ�
# * @update        2006/12/15 mbconvertH2Z��ǉ�
# * @update        2006/12/15 POSIX��strftime�������C���|�[�g�ɕύX
# * @update        2007/02/20 getCookies��ǉ�
# * @update        2007/03/31 ���[���A�h���X�̃h���C������L�����A������Ԃ�
# * @update        2007/05/04 createHash��ǉ�(������MD5�Ōv�Z���Ďw�肵���������ɐ؂�̂Ă�
# * @update        2008/02/07 �g�ю��ʔԍ�getMobileSubscribeNumber
# * @update        2008/03/24 �g�ѓd�b�̃L�����A�R�[�h
# * @update        2008/03/26 �g�ю��ʔԍ�getMobileSubscribeNumber�̏�����ύX
# * @update        2008/03/27 GetTime�Ƀt�H�[�}�b�g�ǉ�
# * @update        2008/03/27 caluculateAge��ǉ�
# * @update        2008/04/07 warnMSG_LINE��ǉ�
# * @update        2008/05/02 checkSanitize�ǉ�
# * @update        2008/05/29 escapeTags
# * @update        2008/06/04 unescapeTags
# * @update        2008/08/27 convertMBStrings2Hex 
#                ���{�ꕶ�����16�i���ϊ�
#                convertHex2MBStrings
#                16�i������{�ꕶ����ɖ߂�
# * @update        2008/10/27 convertSZSpace2C sjis�S�p�X�y�[�X�𔼊p�J���}�ɕϊ�
# * @update        2008/12/04 convertImageSize��ǉ�
# * @update        2009/01/23 getMobileGUID��ǉ�
# * @update        2009/01/28 getCarrierByEMail getCarrierCode getMobileSubscribeNumber getMobileGUID ��JKZ::JKZMoblile�Ɉړ�
# * @update        2009/02/18 �����񑀍�֘A�T�u���[�e�B�������C�� 
# * @update        2009/02/18 ���t�t�H�[�}�b�g�𐮂���T�u���[�e�B���ǉ�
# * @update        2009/02/19 ���W���[���̃R���p�C����K�v�ȂƂ�������require�ɕύX�ǂݍ���
# * @update        2009/03/06 figContentType��ǉ��c�R���e���c�^�C�v
# * @update        2009/03/06 publishObj�ǉ��B
# * @update        2009/03/12 clearObj�ǉ��B
# * @update        2009/07/07 warnTreeLayOut�ǉ�
# * @update        2009/07/28 createDir��ǉ�
# * @update        2009/08/03 convertImageSize��r��
# * @update        2009/08/03 convertByNKF��ǉ�
# * @update        2009/09/07 calculateAge�Ɍ��E���`�F�b�N�����ǉ�
# * @update        2009/09/08 GetTime�ɃI�v�V������ǉ� 13-17
# * @update        2009/09/46 WebUtil::encryptBlowFish WebUtil::decryptBlowFish��ǉ�
#********************************************
package MyClass::WebUtil;

use strict;
our $VERSION = '1.2';

use POSIX qw(strftime);
use Unicode::Japanese;
use Unicode::Japanese qw(unijp);
use NKF;



#////////////////////////////////////////////
# �����񏈗��֌W
#////////////////////////////////////////////

#********************************************
# �T�j�^�C�Y
#********************************************
sub checkSanitize {
    my $str = shift;
    return "" if $str =~ /[\<|\>|\&|\'|\,|\"]/;#"

    return $str;
}


#********************************************
# �ȒP��escape
# < > & " ==> &lt; &gt; &amp; &quot;
#********************************************
sub escapeTags {
    my $str = shift;
    $str =~ s/\</&lt;/g;
    $str =~ s/\>/&gt;/g;
#    $str =~ s/\&/&amp;/g;
    $str =~ s/\"/&quot;/g;#"

    return $str;
}


#********************************************
# �ȒP��escape���ꂽ������unescape
# &lt; &gt; &amp; &quot; ==>  < > & "
#********************************************
sub unescapeTags {
    my $str = shift;
    $str =~ s/&lt;/\</g;
    $str =~ s/&gt;/\>/g;
#    $str =~ s/&amp;/\&/g;
    $str =~ s/&quot;/\"/g;#"

    return $str;
}


#********************************************
# ���s�R�[�h��html�̉��s�^�O�ɕϊ�
#********************************************
sub yenRyenN2br {
    my $str = shift;
    $str =~ s!\r\n!<br />!g;

    return $str;
}


#********************************************
# html�̉��s�^�O�����s�R�[�h�ɕϊ�
#********************************************
sub br2yenRyenN {
    my $str = shift;
    $str =~ s!<br />!\r\n!g;

    return $str;
}


#********************************************
# html�̉��s�^�O�����s�R�[�h�ɕϊ�(���O����ނł͂Ȃ��ꍇ)
#********************************************
sub yenRyenN2brAfterNoTags { 
    my $str = shift;
    $str =~ s!^[^br />]\r\n!<br \/>!g;

    return $str;
}


#********************************************
# html��head�Ȃ�����ނ��G�X�P�[�v
#********************************************
sub escapeHeaderTags {
    my $str = shift;
    $str =~ s!<(html.*?)>!&lt;$1&gt;!g;
    $str =~ s!<(head)>!&lt;$1&gt;!g;
    $str =~ s!<(title)>!&lt;$1!g;
=pod
    $str =~ s!<(meta.*?)!&lt;$1&gt;!g;
    $str =~ s!<(link.*?)!&lt;$1&gt;!g;
    $str =~ s!<(script.*?)!&lt;$1&gt;!g;
    $str =~ s!<(body.*?)!&lt;$1;!g;
=cut
    $str =~ s!<(meta.*?)>!&lt;$1&gt;!g;
    $str =~ s!<(link.*?)>!&lt;$1&gt;!g;
    $str =~ s!<(script.*?)>!&lt;$1&gt;!g;
    $str =~ s!<(body.*?)>!&lt;$1;!g;
    $str =~ s!<(/script)>!&lt;$1&gt;!g;
    $str =~ s!<(/title)>!&lt;$1&gt;!g;
    $str =~ s!<(/head)>!&lt;$1&gt;!g;
    $str =~ s!<(/body)>!&lt;$1&gt;!g;
    $str =~ s!<(/html)>!&lt;$1&gt;!g;

    return $str;
}


#********************************************
# �X�y�[�X���폜
#********************************************
sub trimSpace {
    my $str = shift;
    return "" if !defined $str;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;

    return ($str);
}


#********************************************
# �����Ƀt�H�[�}�b�g����
#********************************************
sub formatToNumber {
    my $str = shift;
    return "" if !defined $str;
    $str =~ s/\D//g;

    return ($str);
}


#********************************************
# �A���t�@�x�b�g�Ƀt�H�[�}�b�g����
#********************************************
sub formatToAlphabet {
    my $str = shift;
    $str = "" if !defined $str;
    $str =~ s/[^a-zA-Z]//g;

    return ($str);
}


#********************************************
# �p�����P��Ƀt�H�[�}�b�g����
#********************************************
sub formatToNumberAlphabet {
    my $str = shift;
    $str = "" if !defined $str;
    $str =~ s/[^_a-zA-Z0-9]//g;

    return ($str);
}


#********************************************
# ���t���Ԃ̃Z�p���[�^�ƒ����𐮂���
# @param strings
# @param hash    {sepfrom =>'', septo=>'', offset=>"", limit=>""}
#********************************************
sub formatDateTimeSeparator {
    my $datetime    = shift || return undef;
    my $hash        = shift || return undef;

    $datetime =~ s!$hash->{sepfrom}!$hash->{septo}!g;
    return (exists($hash->{offset}) ? substr($datetime, $hash->{offset}, $hash->{limit}) : $datetime);
}


#******************************************************
# @desc     yyyyy mm dd HH MM �̎��ԃf�[�^��yyyy-mm-dd HH:MM�ɂ���
# @param    string { yyyy=>"" mm=>"", dd=>"", HH=>", MM=>"" join1=>"" join2=>"" withspace=>[1,0]}
#******************************************************
sub joinDateTime {
    my $datetime = shift || return undef;

    my $ret = sub {
        my $part1 = join( $datetime->{join1}, qw($datetime->{yyyy} $datetime->{mm} $datetime->{dd}) );
        my $part2 = exists($datetime->{HH}) && exists($datetime->{MM}) ? join( $datetime->{join2}, qw($datetime->{HH} $datetime->{MM}) ) : undef;
        return (exists($datetime->{withspace}) ? $part1 . ' ' . $part2 : $part1 . $part2);
    };
    return $ret;
}


#********************************************
# ��P�ʂɃJ���}��}��
#********************************************
sub insertComma {
    my $int = shift;
    1 while $int =~ s/(.*\d)(\d\d\d)/$1,$2/g;

    return ($int);
}


#********************************************
# �����_���o��
#********************************************
sub Round {
  my ($num, $decimals) = @_;
  my ($format, $magic);
  $format = '%.' . $decimals . 'f';
  $magic  = ($num > 0) ? 0.5 : -0.5;
  sprintf($format, int(($num * (10 ** $decimals)) + $magic) /
                   (10 ** $decimals));
}


#********************************************
# �����A�h�`�F�b�N
#********************************************
sub Looks_Like_Email {
    my $str = shift;
    return "" if $str =~ /\s|\,/;
    return "" if $str !~ /\b[-\w.]+@[-\w]+\.[-\w]+\b/;

    return ($str =~ /^[^@]+@[^.]+\.[^.]/);
}


#********************************************
# URL�`�F�b�N ���`�F�b�N
#********************************************
sub checkURL {
    my $str = shift;
    my $urlpattern = qq{s?https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+};

    return ($str =~ /^$urlpattern$/);
}


#********************************************
# �S�p���Ȃ𔼊p���ȕϊ�
#********************************************
sub mbconvertZ2HKana {
    my $str = shift;
    my $tmpstr = Unicode::Japanese->new($str, 'sjis')->get;
    my $ret    = Unicode::Japanese->new($tmpstr)->z2hKana->get;

    return unijp ($ret)->sjis;
}


#********************************************
# ���p���Ȃ�S�p���ȕϊ�
#********************************************
sub mbconvertH2ZKana {
    my $str = shift;
    my $tmpstr = Unicode::Japanese->new($str, 'sjis')->get;
    my $ret    = Unicode::Japanese->new($tmpstr)->h2zKana->get;

    return unijp ($ret)->sjis;
}


#********************************************
# �S�Ĕ��p�ϊ�
#********************************************
sub mbconvertZ2H {
    my $str = shift;
    my $tmpstr = Unicode::Japanese->new($str, 'sjis')->get;
    my $ret    = Unicode::Japanese->new($tmpstr)->z2h->get;

    return unijp ($ret)->sjis;
}


#********************************************
# �S�đS�p�ϊ�
#********************************************
sub mbconvertH2Z {
    my $str = shift;
    my $tmpstr = Unicode::Japanese->new($str, 'sjis')->get;
    my $ret    = Unicode::Japanese->new($tmpstr)->h2z->get;

    return unijp ($ret)->sjis;
}


#********************************************
# utf-8��sjis�ɕϊ�
#********************************************
sub mbconvertU2S {
    my $str = shift;
    return Unicode::Japanese->new($str)->sjis;
}


#********************************************
# sjis��utf-8�ɕϊ�
#********************************************
sub mbconvertS2U {
    my $str = shift;
    return Unicode::Japanese->new($str, 'sjis')->get;
}


#********************************************
# sjis�S�p�X�y�[�X�𔼊p�J���}�ɕϊ�
#********************************************
sub convertSZSpace2C {
    my $str = shift;
    my $Zspace_sjis = '(?:\x81\x40)';

    $str =~ s/(?:\s|$Zspace_sjis)+/,/go;
    return $str;
}


#********************************************
# ���{�ꕶ�����16�i���ϊ�
#********************************************
sub convertMBStrings2Hex {
    my $str = shift || return (undef);
    my $fmt = shift || '%X';

    $str =~ s/(.)/sprintf($fmt, ord($1))/eg;

    return($str);
}


#********************************************
# 16�i������{�ꕶ����ϊ�
#********************************************
sub convertHex2MBStrings {
    my $hex = shift || return (undef);

    $hex =~ tr/+/ /;
    $hex =~ s/([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex ($1))/eg;

    return ($hex);
}

#******************************************************
# @desc     NKF���g�p���Ă̒P���ȕ����R�[�h�ϊ��o��
# @param    flag -j,-s,-e,-w
# @param    str
# @return   str
#******************************************************
sub convertByNKF($$) {
    my ($flag, $str) = @_;
    return undef if $flag !~ /^-[j|s|e|w]$/;

    return ( nkf($flag, $str) );
}

#********************************************
# �������MD5�ŃG���R�[�h
#********************************************
sub encodeMD5 {
    my @val = @_;
    my $key = "This is the key value";

    require Digest::MD5;
    require Crypt::CBC;
    require Crypt::Blowfish;

    my $md     = Digest::MD5->new();
    my $cipher = Crypt::CBC->new($key, "Blowfish");
    my $checksum;
    $md->add(join ("", $key, @val));
    $checksum = $md->hexdigest ();
    return ( $cipher->encrypt_hex( join(":", $checksum, @val) ) );
}


#********************************************
# �������MD5�Ńf�R�[�h
#********************************************
sub decodeMD5 {
    my $ciphertext = shift;
    my $key = "This is the key value";

    require Digest::MD5;
    require Crypt::CBC;
    require Crypt::Blowfish;

    my $md     = Digest::MD5->new();
    my $cipher = Crypt::CBC->new($key, "Blowfish");
    my ($checksum, $checksum2);
    my @val;

    ($checksum, @val) = split (/:/, $cipher->decrypt_hex($ciphertext));
    $md->add (join ("", $key, @val));
    $checksum2 = $md->hexdigest();
    return (@val) if $checksum eq $checksum2;
    return ();
}


#********************************************
# BlowFish�ňÍ���
#********************************************
sub encryptBlowFish {
    my @val = @_;

    require Crypt::CBC;
    my $key    = "key value";
    my $cipher = Crypt::CBC->new($key, "Blowfish");

    return ( $cipher->encrypt_hex(join(":", @val)) );
}

#********************************************
# # BlowFish�ŕ�����
#********************************************
sub decryptBlowFish {
    my $ciphertext = shift;

    require Crypt::CBC;
    my $key    = "key value";
    my $cipher = Crypt::CBC->new($key, "Blowfish");

    my @val = split(/:/, $cipher->decrypt_hex($ciphertext));
    return (@val);
}


#********************************************
# UserAgent, RemoteAddress, RemoteHost,Refere
#********************************************
sub getIP_Host {
    my $agent = $ENV{'HTTP_USER_AGENT'};
    my $addr  = $ENV{'REMOTE_ADDR'};
    my $host  = $ENV{'REMOTE_HOST'} eq '' ? $addr : $ENV{'REMOTE_HOST'};
    if ( $host eq $addr ) {
        $host = gethostbyaddr( pack( 'C4', split( /\./, $host ) ), 2 ) || $addr;
    }
    my $referer = $ENV{'HTTP_REFERER'};
    my $remoteinfo = {
        agent   => $agent,
        ip      => $addr,
        host    => $host,
        referer => $referer,
    };
    return ($remoteinfo);
}

#////////////////////////////////////////////
# ���̑�
#////////////////////////////////////////////


#********************************************
# @access        public 1975�N9��25��15��39��5�b
# @param        int        $WhereStr        �t�H�[�}�b�g���w��
#                0  yyyy-mm-dd hh:mm   1975-09-25 15:39
#                1  yyyy-mm-dd         1975-09-25
#                2  yyyymmdd           19750925
#                3  yyyymmddhhmm       197509251539
#                4  mmddhhss           0925153905
#                5  yyyymm             197509
#                6  yyyy-mm            1975-09
#                7  yyyymmddhhmmss     19750925153905
#                8  mm��               09��
#                9  yyyy               1975
#                10                    1975-09-05 15:39:09
#                11                    09
#                12                    25
#                13                    15:39:09
#                14                    1539
#                15                    15
#                16                    39
#                17                    09
# @return        �w��t�H�[�}�b�g�Ō��݂̎���
#********************************************
sub GetTime {
    #my $opt = shift;
    my ($opt, $additional) = @_;
    $ENV{'TZ'} = "Japan";
    my @pattern = (
        "%Y-%m-%d %H:%M",
        "%Y-%m-%d",
        "%Y%m%d",
        "%Y%m%d%H%M",
        "%m%d%H%M%S",
        "%Y%m",
        "%Y-%m",
        "%Y%m%d%H%M%S",
        "%m��%d" . $additional . "��",
        "%Y",
        "%Y-%m-%d %H:%M:%S",
        "%m",
        "%d",
        "%H:%M:%S",
        "%H%M",
        "%H",
        "%M",
        "%S",
    );
    my $time = strftime("$pattern[$opt]", localtime);

    return ($time);
}


#******************************************************
# @desc        ���N��������N����v�Z
# @param    1975-09-23�̃t�H�[�}�b�g
# @return    $age
#******************************************************
sub calculateAge {
    my $birthday = shift;

    return "" if !defined $birthday;
    return "" if $birthday !~ /\d\d\d\d-\d\d-\d\d/;

    my ($Y, $m, $d) = split /-/, $birthday;

    ## Modified 2009/09/07 BEGIN
    my @MON        = (1..12);
    my @DATE    = (1..31);
    return undef unless $m == $MON[$m -1];
    return undef unless $d == $DATE[$d - 1];
    ## Modified 2009/09/07 END

    my $age = (GetTime("9") - $Y);
    if ( (GetTime("11") * 100 + GetTime("12") ) < ($m * 100 + $d)) { --$age; }

    ## �N��̏���l��100�΂�ݒ�
    return (1 < $age && $age < 100) ? $age : undef;
#    return (1 < $age)  ? $age : undef;
}


#********************************************
# ���ԑ���
#********************************************
sub benchmarkMicrotime {
    my ($opt, $microtime) = @_;
    use Time::HiRes qw(gettimeofday tv_interval);
    return [gettimeofday] if 1 == $opt;

    return tv_interval $microtime->{t0},$microtime->{t1} if 2 == $opt;
}


#********************************************
# Get Cookie
#********************************************
sub getCookies {
    map { split /=/, $_, 2 } split /; /, $ENV{'HTTP_COOKIE'};
}


#******************************************************
# @desc        MD5�ň������v�Z���Ĉ����Ŏw�肵�������ɂ���
# @param    $value = MD5�Ōv�Z����l
#            $length = �w�蒷��
# @return    
#******************************************************
sub createHash {
    my ($value, $length) = @_;

    require Digest::MD5;
    my $md = Digest::MD5->new();
    $md->add($value);
    return substr($md->hexdigest, 0, $length);
}


#******************************************************
# @desc        ���[�U�[�Ƀ��j�[�NID�𔭍s����
# @return    UniqueNumber
#******************************************************
sub generateOrderID {
    $ENV{'TZ'} = "Japan";
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $orderid = sprintf("%04d%02d%02d%02d%02d%02d",$year +1900,$mon +1,$mday,$hour,$min,$sec);
    return ($orderid);
}



#******************************************************
# @desc        �g���q����t�@�C���^�C�v���擾����E�R���e���c�^�C�v����g���q���擾
# @param    $path/to/$file
# @return    
#******************************************************
sub figContentType {
    my $filename = shift || return undef;

    #*********************************
    # �t�@�C���g���q�ƃR���e���c�^�C�v
    # Modified AU/DoCoMo/SoftBank�f�R���e���v���[�g�p�ǉ�2009/04/28
    #*********************************
    my %CONTENT_TYPE = (
        "jpg"  => "image/jpeg",
        "jpeg" => "image/jpeg",
        "gif"  => "image/gif",
        "bmp"  => "image/bmp",
        "png"  => "image/png",
        "js"   => "text/plain",
        "css"  => "text/css",
        "pdf"  => "application/pdf",
        "rdf"  => "application/rtf",
        "doc"  => "application/msword",
        "xls"  => "application/vnd.ms-excel",
        "swf"  => "application/x-shockwave-flash",
        "xml"  => "text/xml",
        "txt"  => "text/plain",
        "ico"  => "image/x-icon",
        "flv"  => "application/octet-stream",
        "php"  => "text/plain",
        "htm"  => "text/html",
        "html" => "text/html",
        "csv"  => "application/octet-stream",
        "dmt"  => "AddType application/x-decomail-template",
        "hmt"  => "AddType application/x-htmlmail-template",
        "khm"  => "application/x-kddi-htmlmail",
    );

    return ($CONTENT_TYPE{$1}) if $filename =~ /\.([^.]+)$/;

    #*********************************
    # �R���e���c�^�C�v�ƃt�@�C���g���q
    #*********************************
=pod
    my %CONTENT_TYPE_2 = (
        "image/jpeg"                    => "jpg",
        "image/pjpeg"                    => "jpg",
        "image/gif"                        => "gif",
        "image/bmp"                        => "bmp",
        "image/x-bmp"                    => "bmp",
        "image/png"                        => "png",
        "text/css"                        => "css",
        "application/pdf"                => "pdf",
        "application/x-pdf"                => "pdf",
        "application/rtf"                => "rtf",
        "text/richtext"                    => "rtf",
        "application/msword"            => "doc",
        "application/vnd.ms-excel"        => "xls",
        "application/x-shockwave-flash"    => "swf",
        "text/xml"                        => "xml",
        "text/plain"                    => "txt",
        "image/x-icon"                    => "ico",
        "text/html"                        => "html",
    );
=cut
}


#******************************************************
# @desc        �w��t�@�C�����I�[�v�����ē��e��Ԃ�
# @param    $path/to/$file
# @return    
#******************************************************
sub openFileIntoScalar {
    my $file = shift;

    return "" if !defined $file;

    my $retfile;

    local $/;
    local *F;
    open (F, "< $file\0") || return;
    $retfile = <F>;
    close (F);

    return ($retfile);
}


#******************************************************
# @desc        �f�B���N�g���쐬
# @param    str        $path_to_directory
# @return    boolean (���s�̏ꍇ���G���[���o�͂��邩�玩���Ń`�F�b�N)
#******************************************************
sub createDir {
    my $directory_path = shift || return undef;
    my $umask = shift || 0777;
    
    use File::Path;
    eval {
        mkpath($directory_path, 1, $umask);
    };

    if ($@) {
        warn " Fail creating directory $directory_path.  $@ \n";
        return undef;
    }

    return 1;
}


#******************************************************
# @desc        �V���A���C�Y���ĕۑ�
# @param    hashobj {file=> path/to/filenem obj=>{}}
#            store if hashobj->{obj} exists or retrieve by file
# @return    
#******************************************************
sub publishObj {
    my $obj = shift || return undef;
    use Storable qw( nstore retrieve );
    return( exists($obj->{obj}) ? nstore $obj->{obj}, $obj->{file} : retrieve $obj->{file} );
}


#******************************************************
# @desc        �V���A���C�Y�I�u�W�F�N�g���폜
#******************************************************
sub clearObj {
    my $obj = shift || return undef;
    return(unlink($obj));
}


#******************************************************
# @desc        Cached::Memcached�𗘗p�����I�u�W�F�N�g���擾
# @param    $key $value
# @return    $object
#******************************************************
sub getCachedByCGI {
    my ($key, $value) = @_;
    if (!defined $key || !defined $value) {
        return;
    }
    require Cache::Memcached;
    my $memcached = Cache::Memcached->new({'servers' => ["127.0.0.1:11211"]});
    my $obj = $memcached->get("$key:$value");

    return $obj;
}


#******************************************************
# @desc     �f�o�b�O�p��Warn�̃��b�Z�[�W���o��
# @param    $str
# @return    
#******************************************************
sub warnMSG_LINE {
    my ($str, $LINE) = @_;
    my $timenow = &GetTime(10);
    #use UNIVERSAL::require;
    #Data::Dumper->require;
    use Data::Dumper;
    warn "====="x10,"\n [",$timenow, "] [LINE:", $LINE, "] ",Dumper($str),  "\n", "====="x10,"\n";
}


#******************************************************
# @desc        �f�o�b�O�p��Warn�̃��b�Z�[�W��WEB�o�͗p��
# @param    $str
# @return    $str dump strings
#******************************************************
sub warnMSGtoBrowser {
    my ($str, $LINE) = @_;

    require Data::Dumper;
    my $dumpstr = "====="x10 . "<br /> [LINE:" . $LINE . "]<br /> " . Dumper($str) .  "<br />" . "====="x10 . "\n";
    #$dumpstr =~ s/\n/<br \/>/g;
#    $dumpstr =~ s/(],)/$1<br \/>/g;
    return ($dumpstr);
}


#******************************************************
# @desc        �f�o�b�O�p�ɖ؍\���̃f�[�^���o��
# @param    $str layout printflag
# @return    
#******************************************************
sub warnTreeLayOut {
    my ($str, $layout, $printflag) = @_;

    $layout    ||= "0";
    $printflag ||= "0";

    require Text::Tree;
    my $root = 'TOP';
    my @layoutarray = ('boxed', 'center', 'oval');
    my $tree = Text::Tree->new($root, $str);

    0 < $printflag ? warn $tree->layout($layoutarray[$layout]) : return $tree->layout($layoutarray[$layout]);
}


1;
__END__
