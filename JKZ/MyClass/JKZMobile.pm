#******************************************************
# @desc        携帯電話処理クラス 古いJKZMobileとバッティングするのでJKZMobileに名前変更
# @package    MyClass::JKZMobile
# @access    public
# @author    Iwahase Ryo
# @create    2009/01/28
# @update    2009/03/30 convertEmojiCodeの変換テーブルの修正と正規表現修正に49%アップ
# @update    2009/05/18 getSubscribenumberメソッドの不具合修正
# @update    2009/05/18 convertEmojicodeメソッドの不具合修正
# @update    2009/05/18 xhtmlCapableメソッド追加
# @update    2009/06/03    getDCMGUIDを更新 
# @update    2009/07/06    myAgentのいい加減な説明を修正とgetSubscribeNumberメソッドを修正
# @update    2009/07/27    AM KDDI_DeviceIDDevice2Name
# @version    2.00
#******************************************************
package MyClass::JKZMobile;

use 5.008005;
our $VERSION = '1.00';

use strict;

use HTTP::MobileAgent;
use Encode;
use Encode::JP::Mobile;


#******************************************************
# @access    
# @desc        インスタンス生成
# @return    
#******************************************************
sub new {
    my $class = shift;

    my $self =  bless {}, $class;

    my $agent = HTTP::MobileAgent->new;
    $self->{agent} = $agent;
    $self->init;

    return $self;
}


sub init {
}


#******************************************************
# @access    
# @desc        アクセサ
# @return 
# <<<DoCoMo>>>
#    $agent->is_docomo       # true
#    $agent->user_id         # AYc3x8e                    guid=ONから取得できる sslは非対応
#    $agent->serial_number   # NMABH200331                utnから取得するserで始まる部分「 DoCoMo/1.0/P503i/c10/serNMABH200331」
#    $agent->card_id         # 01234567890123456789        フォーマのカードID
#    $agent->name            # DoCoMo
#    $agent->version         # 1.0
#    $agent->html_version    # 2.0
#    $agent->model           # P502i
#    $agent->cache_size      # 10
#    $agent->is_foma         # false                        フォーマかどうか
#    $agent->vendor          # P’
#    $agent->series          # 502i
#    $agent->xhtml_compliant # true                        「DoCoMo/2.0 SO902i(c100TBW30H16)」
#    $agent->comment         # Google CHTML Proxy/1.0    「DoCoMo/1.0/P502i (Google CHTML Proxy/1.0)」
#    $agent->status          # TB                        「DoCoMo/1.0/D505i/c20/TB/W20H10」
#
# <<<EZweb>>>
#    $agent->is_ezweb        # true
#    $agent->user_id         # 05005010970587_gj.ezweb.ne.jp 「$ENV{'HTTP_X_UP_SUBNO'} 14桁の数値]_[2桁の英字].ezweb.ne.jp」
#    →$agent->serial_number # 無し
#    $agent->name            # "UP.Browser"
#    $agent->version         # 3.01
#    $agent->device_id       # HI02
#    $agent->server          # "UP.Link/3.2.1.2"
#    $agent->xhtml_compliant # true
#    $agent->comment         # "Google WAP Proxy/1.0"
#    $agent->is_tuka         # FALSE
#    $agent->is_win          # TRUE
#
# <<<SoftBank>>>
#    $agent->is_vodafone     # true
#    $agent->user_id         # a2flDWhwLmAxCoQ0             「$ENV{'HTTP_X_JPHONE_UID'}」
#    $agent->serial_number   # XXXXXXXXX                    「J-PHONE/4.0/J-SH51/SNXXXXXXXXX SH/0001a Profile/MIDP-1.0 Configuration/CLDC-1.0 Ext-Profile/JSCL-1.1.0」
#    $agent->name            # J-PHONE
#    $agent->version         # 2.0
#    $agent->model           # "J-D02"
#    $agent->xhtml_compliant # False
#    $agent->vendor          # 'SH'
#    $agent->vendor_version  # "0001a"
#    $agent->java_info       # in HASH
#    $agent->is_type_c       # 
#    $agent->is_type_p       # 
#
#    <<xhtml対応機種の判別>>
#    DoCoMo        $agent->is_foma
#    EzWeb        $agent->is_win
#    SoftBank    $agent->is_type_w $agent->is_type_3gc
#
#******************************************************
sub myAgent {
    my $self = shift;

    return $self->{agent};
}


#********************************************
# @desc        携帯電話端末のがxhtml対応かの判定
# @param    
# @return    boolean 
#********************************************
sub xhtmlCapable {
    my $self = shift;

    return ($self->myAgent->xhtml_compliant ? 1 : undef);
}

#********************************************
# @desc        携帯電話端末のエンコーディング
#            携帯電話以外はshift_jisとする
# @param    agent
# @return    
#********************************************
sub detectEncoding {
    my $self = shift;
    my $agent = $self->myAgent();

    if ($agent->is_docomo) {
        $self->{encoding} = $agent->xhtml_compliant ? 'x-sjis-imode' : 'x-sjis-docomo';
    } elsif ($agent->is_ezweb) {
        $self->{encoding} = 'x-sjis-kddi-auto';
    } elsif ($agent->is_vodafone) {
        $self->{encoding} = $agent->is_type_3gc ? 'x-sjis-softbank' : 'x-sjis-softbank';
    } else {
        $self->{encoding} = 'sjis';
    }

    return ($self->{encoding});
}


#********************************************
# @desc        携帯電話端末からのデータをデコード
# @param    char $text
# @return    
#********************************************
sub decodeText {
    my ($self, $text) = @_;
    my $encoding = $self->detectEncoding();

    my $decoded = decode($encoding, $text);

    return ($decoded);
}


#********************************************
# @desc        携帯電話端末からのデータをエンコード
# @param    char $text
# @param    boolean $flag １の場合は絵文字相互交換をする
# @return    
#********************************************
sub encodeText {
    my ($self, $text, $flag) = @_;
    my $encoding = $self->detectEncoding();

    my $encoded  = $flag ? encode($encoding, $text, Encode::JP::Mobile::FB_CHARACTER) :  encode($encoding, $text);

    return ($encoded);
}


#********************************************
# @desc     任意のコードにエンコード
# @param    
# @return   
#********************************************
sub decode_to {
    my ($encoding, $text) = @_;
    return (decode($encoding, $text));
}


#********************************************
# @desc        メルアドドメインから携帯電話のキャリアコードを決定
# @param    Mailaddress
# @return    docomo=1 softbank=2 ezweb=3 else=4
#********************************************
sub getCarrierCodeByEMail {
    my ($self, $str) = @_;

    return ($self->{carriercode} = "4") if "" eq $str;

    $self->{carriercode} = 
        ( $str =~ /\@docomo\.ne\.jp$/ )                 ? "1" :
        ( $str =~ /\@.\.[vodafone|softbank]\.ne\.jp$/ ) ? "2" :
        ( $str =~ /\@ezweb\.ne\.jp$/ )                  ? "3" :
                                                          "1" ; # "4" For SoftBank test

    return $self->{carriercode};
}


#********************************************
# @desc        UserAgentから携帯電話のキャリアコードを決定
# @param    HTTP_USER_AGENT
# @return    docomo=1 softbank=2 ezweb=3 else=4
#********************************************
sub getCarrierCode {
    my $self = shift;

    my $agent = $self->myAgent();

    $self->{carriercode} = 
        ( $agent->is_docomo )   ? "1" :
        ( $agent->is_vodafone ) ? "2" :
        ( $agent->is_ezweb )    ? "3" :
                                  "1" ; # "4" For SoftBank test

    return $self->{carriercode};
}


#******************************************************
# @desc        携帯電話の固体識別番号取得
# @param    HTTP_USER_AGENT / HTTP_X_UP_SUBNO
# @return    固体識別番号
#******************************************************
sub getSubscribeNumber {
    my $self = shift;

    return if $self->myAgent->is_non_mobile;

    $self->{subscribenumber} = $self->myAgent->is_docomo || $self->myAgent->is_vodafone ? $self->myAgent->serial_number : $self->myAgent->user_id;

    return ($self->{subscribenumber});
}


#******************************************************
# @desc        携帯電話の契約者固有IDの取得 機種変更しても変わらないID
#            リンクパラメータに ?guid=onで取得
# @param    HTTP_X_DCMGUID HTTP_X_JPHONE_UID / HTTP_X_UP_SUBNO
# @return    契約者固有ID
#******************************************************
sub getDCMGUID {
    my $self = shift;
    $self->{DCMGUID} =
        ( exists($ENV{'HTTP_X_DCMGUID'}) )    ? $ENV{'HTTP_X_DCMGUID'}    :
        ( exists($ENV{'HTTP_X_JPHONE_UID'}) ) ? $ENV{'HTTP_X_JPHONE_UID'} :
        ( exists($ENV{'HTTP_X_UP_SUBNO'}) )   ? $ENV{'HTTP_X_UP_SUBNO'}   :
                                                    undef                 ;

    return ($self->{DCMGUID});
}


#******************************************************
# @desc        KDDI(AU)端末のデバイスIDから機種名取得
# @param    
# @return    $str 機種名 / undef
#******************************************************
sub KDDI_DeviceID2DeviceName {
    my $self = shift;

    ## アクセス端末がAUではない場合は判定しない。
    unless ($self->myAgent->is_ezweb()) {
        return undef;
    }
    
    my %hash = (
         "HI3G"    => "Mobile Hi-Vision CAM Wooo"
        ,"KC3Q"    => "misora[iida]"
        ,"TS3O"    => "biblio"
        ,"TS3P"    => "T002"
        ,"SH3B"    => "SH002"
        ,"KC3O"    => "K002"
        ,"SH3C"    => "Sportio water beat"
        ,"CA3E"    => "CA002"
        ,"SN3K"    => "G9[iida]"
        ,"SN3J"    => "S001"
        ,"PT35"    => "NS02"
        ,"MA35"    => "P001"
        ,"TS3N"    => "T001"
        ,"HI3F"    => "H001"
        ,"SH38"    => "SH001"
        ,"CA3D"    => "CA001"
        ,"SN3I"    => "Premier3"
        ,"KC3N"    => "NS01"
        ,"KC3M"    => "K001"
        ,"SN3H"    => "Xmini"
        ,"HI3E"    => "W63H"
        ,"TS3M"    => "W65T"
        ,"CA3C"    => "W63CA"
        ,"SH37"    => "W64SH"
        ,"KC3I"    => "W65K"
        ,"SN3G"    => "W64S"
        ,"MA34"    => "W62P"
        ,"TS3L"    => "W64T"
        ,"KC3K"    => "W63Kカメラ無し"
        ,"SH36"    => "URBANO"
        ,"PT34"    => "W62PT"
        ,"SA3E"    => "W64SA"
        ,"CA3B"    => "W62CA"
        ,"HI3D"    => "W62H"
        ,"SH35"    => "W62SH"
        ,"SN3F"    => "re"
        ,"KC3H"    => "W63K"
        ,"TS3K"    => "Sportio"
        ,"TS3J"    => "W62T"
        ,"SA3D"    => "W63SA"
        ,"KC3G"    => "W62K"
        ,"SN3D"    => "W61S"
        ,"SA3C"    => "W61SA"
        ,"SN3E"    => "W62S"
        ,"TS3I"    => "W61T"
        ,"HI3C"    => "W61H"
        ,"ST34"    => "W62SA"
        ,"PT33"    => "W61PT"
        ,"MA33"    => "W61P"
        ,"CA3A"    => "W61CA"
        ,"KC3D"    => "W61K"
        ,"SA3B"    => "W54SA"
        ,"SH34"    => "W61SH"
        ,"SN3C"    => "W54S"
        ,"TS3H"    => "W56T"
        ,"TS3G"    => "W55T"
        ,"HI3B"    => "W53H"
        ,"KC3B"    => "W53K/W64K"
        ,"ST33"    => "INFOBAR 2"
        ,"KC3E"    => "W44K IIカメラなしモデル"
        ,"SN3B"    => "W53S"
        ,"CA39"    => "W53CA"
        ,"ST32"    => "W53SA"
        ,"TS3E"    => "W54T"
        ,"SH33"    => "W52SH"
        ,"CA38"    => "W52CA"
        ,"MA32"    => "W52P"
        ,"SN3A"    => "W52S"
        ,"TS3D"    => "W53T"
        ,"SA3A"    => "W52SA"
        ,"HI3A"    => "W52H"
        ,"KC3A"    => "MEDIA SKIN"
        ,"SH32"    => "W51SH"
        ,"SN39"    => "W51S"
        ,"TS3C"    => "W52T"
        ,"TS3B"    => "W51T"
        ,"SA39"    => "W51SA"
        ,"HI39"    => "W51H"
        ,"CA37"    => "W51CA"
        ,"MA31"    => "W51P"
        ,"KC39"    => "W51K"
        ,"TS39"    => "DRAPE"
        ,"TS3A"    => "W47T"
        ,"SN38"    => "W44S"
        ,"KC38"    => "W44K/K II"
        ,"SA38"    => "W43SA"
        ,"TS38"    => "W45T"
        ,"CA35"    => "W43CA"
        ,"HI38"    => "W43H/H II"
        ,"SN37"    => "W43S"
        ,"KC37"    => "W43K"
        ,"ST31"    => "W42SA"
        ,"SH31"    => "W41SH"
        ,"CA34"    => "W42CA"
        ,"HI37"    => "W42H"
        ,"TS37"    => "W44T/T II/T III"
        ,"TS35"    => "neon"
        ,"TS36"    => "W43T"
        ,"SN36"    => "W42S"
        ,"KC36"    => "W42K"
        ,"KC35"    => "W41K"
        ,"SA36"    => "W41SA"
        ,"TS34"    => "W41T"
        ,"HI36"    => "W41H"
        ,"CA33"    => "W41CA"
        ,"SN34"    => "W41S"
        ,"HI34"    => "PENCK"
        ,"SA35"    => "W33SA/SA II"
        ,"TS33"    => "W32T"
        ,"SA34"    => "W32SA"
        ,"KC34"    => "W32K"
        ,"HI35"    => "W32H"
        ,"SN33/SN35"    => "W32S"
        ,"CA32"    => "W31CA"
        ,"TS32"    => "W31T"
        ,"SN32"    => "W31S"
        ,"KC33"    => "W31K/K II"
        ,"SA33"    => "W31SA/SA II"
        ,"SA32"    => "W22SA"
        ,"HI33"    => "W22H"
        ,"CA31"    => "W21CA/CA II"
        ,"TS31"    => "W21T"
        ,"SA31"    => "W21SA"
        ,"SN31"    => "W21S"
        ,"KC32"    => "W21K"
        ,"HI32"    => "W21H"
        ,"KC31"    => "W11K"
        ,"HI31"    => "W11H"
        ,"SH39"    => "E05SH"
        ,"CA36"    => "E03CA"
        ,"SA37"    => "E02SA"
        ,"ST2C"    => "Sweets cute"
        ,"ST29"    => "Sweets pure"
        ,"CA28"    => "G'zOne TYPE-R"
        ,"ST26"    => "Sweets"
        ,"ST25"    => "talby"
        ,"ST22"    => "INFOBAR"
        ,"TS2E"    => "A5529T"
        ,"KC2A"    => "A5528K"
        ,"SA2A"    => "A5527SA"
        ,"KC29"    => "A5526K"
        ,"ST2D"    => "A5525SA"
        ,"TS2D"    => "A5523T"
        ,"SA29"    => "A5522SA"
        ,"KC28"    => "A5521K"
        ,"ST2A"    => "A5520SA/SA II"
        ,"ST28"    => "A5518SA"
        ,"TS2C"    => "A5517T"
        ,"TS2B"    => "A5516T"
        ,"KC27"    => "A5515K"
        ,"ST27"    => "A5514SA"
        ,"CA27"    => "A5512CA"
        ,"TS2A"    => "A5511T"
        ,"TS29"    => "A5509T"
        ,"ST24"    => "A5507SA"
        ,"TS28"    => "A5506T"
        ,"SA27"    => "A5505SA"
        ,"TS27"    => "A5504T"
        ,"SA26"    => "A5503SA"
        ,"KC24/KC25"    => "A5502K"
        ,"TS26"    => "A5501T"
        ,"CA26"    => "A5407CA"
        ,"CA25"    => "A5406CA"
        ,"ST23"    => "A5405SA"
        ,"SN25"    => "A5404S"
        ,"CA24"    => "A5403CA"
        ,"SN24"    => "A5402S"
        ,"CA23"    => "A5401CA II"
        ,"CA23"    => "A5401CA"
        ,"ST21"    => "A5306ST"
        ,"KC22"    => "A5305K"
        ,"TS24"    => "A5304T"
        ,"HI24"    => "A5303H II"
        ,"HI23"    => "A5303H"
        ,"CA22"    => "A5302CA"
        ,"TS23"    => "A5301T"
        ,"TS21"    => "C5001T"
        ,"SA22"    => "A3015SA"
        ,"SN21"    => "A3014S"
        ,"TS22"    => "A3013T"
        ,"CA21"    => "A3012CA"
        ,"SA21"    => "A3011SA"
        ,"MA21"    => "C3003P"
        ,"KC21"    => "C3002K"
        ,"HI21"    => "C3001H"
        ,"PT23"    => "A1407PT"
        ,"PT22"    => "A1406PT"
        ,"PT21"    => "A1405PT"
        ,"SN29"    => "A1404S/S II"
        ,"KC26"    => "A1403K"
        ,"SN27"    => "A1402S II"
        ,"SN28"    => "A1402S IIカメラ無し"
        ,"SN26"    => "A1402S"
        ,"KC23"    => "A1401K"
        ,"SA28"    => "A1305SA"
        ,"TS25"    => "A1304T II"
        ,"TS25"    => "A1304T"
        ,"TS25"    => "A1304Tカメラ無し"
        ,"SA25"    => "A1303SA"
        ,"SA24"    => "A1302SA"
        ,"SN23"    => "A1301S"
        ,"SN22"    => "A1101S"
        ,"KC26"    => "B01K"
    );

    my $device_id = $self->myAgent->device_id();
    $self->{KDDI_DeviceName} = ( exists($hash{$device_id}) ) ? $hash{$device_id} : undef;

    return $self->{KDDI_DeviceName};
}

#******************************************************
# @desc        DoCoMoの16進数絵文字コードからSoftBankおよびAU対応コードに変換
# @
# @
#******************************************************
sub convertEmojiCode {
    my ($self, $text) = @_;
    my $code        = EmojiCode();
    my $carriercode = $self->getCarrierCode();
    my $regexall    = qr/(&#x)(E\d[0-9A-Z].+?)(;)$/;
    $text =~ s{ $regexall }{ exists($code->{$2}) ? $1 . $code->{$2}->[($carriercode - 2)] . $3 : ""}gex if 1 != $carriercode;

    return $text;
}


#******************************************************
# @desc        DoCoMoの16進数絵文字コードからSoftBankおよびAU対応コードに変換
# @desc        $text =~ { \&\#(F\d\s.+?)\; }{ exists($c->{$1}) ? \&\#$c->{$1}->[$carriercode-2]\; : ""}gex;
# @return    コード
#******************************************************
sub EmojiCode {
    my $c = {};
    while (<DATA>) {
        chomp $_;
        my @d   = split ',', $_;
        my $key = shift @d;
        $c->{$key} = \@d;
    }
    return $c;
}


1;

__DATA__
E63E,E04A,E488
E63F,E049,E48D
E640,E04B,E48C
E641,E048,E485
E642,E13D,E487
E643,E443,E469
E644,E049,E598
E645,E43C,EAE8
E646,E23F,E48F
E647,E240,E490
E648,E241,E491
E649,E242,E492
E64A,E243,E493
E64B,E244,E494
E64C,E245,E495
E64D,E246,E496
E64E,E247,E497
E64F,E248,E498
E650,E249,E499
E651,E24A,E49A
E652,E319,E46B
E653,E016,E4BA
E654,E014,E599
E655,E015,E4B7
E656,E018,E4B6
E657,E013,EAAC
E658,E42A,E59A
E659,E132,E4B9
E65A,E128,E59B
E65B,E01E,E4B5
E65C,E434,E5BC
E65D,E435,E4B0
E65E,E01B,E4B1
E65F,E42E,E4B1
E660,E159,E4AF
E661,E202,EA82
E662,E01D,E4B3
E663,E036,E4AB
E664,E038,E4AD
E665,E153,E5DE
E666,E155,E5DF
E667,E14D,E4AA
E668,E154,E4A3
E669,E158,EA81
E66A,E156,E4A4
E66B,E03A,E571
E66C,E14F,E4A6
E66D,E14E,E46A
E66E,E151,E4A5
E66F,E043,E4AC
E670,E045,E597
E671,E044,E4C2
E672,E047,E4C3
E673,E120,E4D6
E674,E13E,E51A
E675,E313,E516
E676,E03C,E503
E677,E03D,E517
E678,E236,E555
E679,E124,E46D
E67A,E30A,E508
E67B,E502,E59C
E67C,E503,EAF5
E67D,E506,E59E
E67E,E125,E49E
E67F,E30E,E47D
E680,E208,E47E
E681,E008,E515
E682,E323,E49C
E683,E148,E49F
E684,E314,E59F
E685,E112,E4CF
E686,E34B,E5A0
E687,E009,E596
E688,E00A,E588
E689,E301,EA92
E68A,E12A,E502
E68B,E12B,E4C6
E68C,E126,E50C
E68D,E20C,EAA5
E68E,E20E,E5A1
E68F,E20D,E5A2
E690,E20F,E5A3
E691,E419,E5A4
E692,E41B,E5A5
E693,E010,EB83
E694,E011,E5A6
E695,E012,E5A7
E696,E238,E54D
E697,E237,E54C
E698,E536,EB2A
E699,E007,EB2B
E69A,E419,E4FE
E69B,E20A,E47F
E69C,E219,E5A8
E69D,E04C,E5A9
E69E,E04C,E5AA
E69F,E04C,E486
E6A0,E332,E489
E6A1,E052,E4E1
E6A2,E04F,E4DB
E6A3,E01C,E4B4
E6A4,E033,E4C9
E6A5,E239,E556
E6CE,E104,EB08
E6CF,E103,EB62
E6D0,E00B,E520
E6D1,E00A,E577
E6D2,E00A,E577
E6D3,E103,E521
E6D4,E537,E54E
E6D5,E537,E54E
E6D6,E12F,E57D
E6D7,E216,E578
E6D8,E229,EA88
E6D9,E03F,E519
E6DA,E235,E55D
E6DB,E23B,E5AB
E6DC,E114,E518
E6DD,E212,E5B5
E6DE,E12B,EB2C
E6DF,E211,E596
E6E0,E210,EB84
E6E1,E336,E52C
E6E2,E21C,E522
E6E3,E21D,E523
E6E4,E21E,E524
E6E5,E21F,E525
E6E6,E220,E526
E6E7,E221,E527
E6E8,E222,E528
E6E9,E223,E529
E6EA,E224,E52A
E6EB,E225,E5AC
E70B,E24D,E5AD
E6EC,E022,E595
E6ED,E327,EB75
E6EE,E023,E477
E6EF,E327,E478
E6F0,E057,E471
E6F1,E059,E472
E6F2,E058,EAC0
E6F3,E407,EAC3
E6F4,E406,E5AE
E6F5,E236,EB2D
E6F6,E03E,E5BE
E6F7,E123,E4BC
E6F8,E206,E536
E6F9,E003,E4EB
E6FA,E32E,EAAB
E6FB,E10F,E476
E6FC,E334,E4E5
E6FD,E00D,E4F3
E6FE,E311,E47A
E6FF,E326,E505
E700,E238,EB2E
E701,E13C,E475
E702,E021,E482
E703,E336,EB2F
E704,E337,EB30
E705,E330,E5B0
E706,E331,E5B1
E707,E331,E4E6
E708,E330,E4F4
E709,E330,EB7C
E70A,E330,EB31
E6AC,E324,E4BE
E6AD,E12F,E4C7
E6AE,E301,EB03
E6B1,E233,E4FC
E6B2,E11F,EB1C
E6B3,E44B,EAF1
E6B7,E234,E552
E6B8,E23C,EB7A
E6B9,E235,E553
E6BA,E02D,E594
E70C,E00A,E588
E70D,E00A,E588
E70E,E006,E5B6
E70F,E12F,E504
E710,E31C,E509
E711,E006,EB77
E712,E013,E4B8
E713,E325,E512
E714,E036,E4AB
E715,E12F,E4C7
E716,E00C,E5B8
E717,E103,EB78
E718,E00C,E587
E719,E301,E4A1
E71A,E10E,E5C9
E71B,E034,E514
E71C,E026,E47C
E71D,E136,E4AE
E71E,E338,EAAE
E71F,E027,E57A
E720,E403,EAC0
E721,E40A,EAC5
E722,E331,E5C6
E723,E108,E5C6
E724,E416,EB5D
E725,E40E,EAC9
E726,E106,E5C4
E727,E00E,E4F9
E728,E105,E4E7
E729,E405,E5C3
E72A,E40A,EAC5
E72B,E406,EAC2
E72C,E402,EABF
E72D,E411,E473
E72E,E413,EB69
E72F,E333,E551
E730,E301,E4A0
E731,E24E,E558
E732,E537,E54E
E733,E115,E46B
E734,E315,E4F1
E735,E332,EB79
E736,E24F,E559
E737,E252,E481
E738,E333,E541
E739,E22B,EA8A
E73A,E30D,E4F0
E73B,E22A,EA89
E73C,E231,EB7A
E73D,E233,EB7B
E73E,E157,EA80
E73F,E43E,EB7C
E740,E03B,E5BD
E741,E110,E513
E742,E306,E4D2
E743,E304,E4E4
E744,E349,EB35
E745,E345,EAB9
E746,E110,EB7D
E747,E118,E4CE
E748,E030,E4CA
E749,E342,E4D5
E74A,E046,E4D0
E74B,E30B,EA97
E74C,E340,E5B4
E74D,E339,EAAF
E74E,E441,EB7E
E74F,E523,E4E0
E750,E055,E4DC
E751,E019,E49A
E752,E056,EACD
E753,E404,EB80
E754,E01A,E4D8
E755,E10B,E4DE
E756,E044,E4C1
E757,E107,E5C5
E683,E209,E480
__END__
