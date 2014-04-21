#********************************************
# * @desc        文字列操作や変換そのたメルアドチェックや時間取得等のツール群
# * @desc        旧バージョンのWebUtilを利用してるクラス(JKZHPEditなど)が存在するためバージョンアップではなく、モジュール名を変更して対応
# * @package    MyClass::WebUtil
# * @access     public
# * @author     RyoIwahase
# * @create    
# * @version    1.2
# * @update        2006/12/15 mbconvertZ2HKanaを追加
# * @update        2006/12/15 mbconvertH2ZKanaを追加
# * @update        2006/12/15 mbconvertZ2Hを追加
# * @update        2006/12/15 mbconvertH2Zを追加
# * @update        2006/12/15 POSIXのstrftimeだけをインポートに変更
# * @update        2007/02/20 getCookiesを追加
# * @update        2007/03/31 メールアドレスのドメインからキャリア数字を返す
# * @update        2007/05/04 createHashを追加(引数をMD5で計算して指定した文字数に切り捨てる
# * @update        2008/02/07 携帯識別番号getMobileSubscribeNumber
# * @update        2008/03/24 携帯電話のキャリアコード
# * @update        2008/03/26 携帯識別番号getMobileSubscribeNumberの処理を変更
# * @update        2008/03/27 GetTimeにフォーマット追加
# * @update        2008/03/27 caluculateAgeを追加
# * @update        2008/04/07 warnMSG_LINEを追加
# * @update        2008/05/02 checkSanitize追加
# * @update        2008/05/29 escapeTags
# * @update        2008/06/04 unescapeTags
# * @update        2008/08/27 convertMBStrings2Hex 
#                日本語文字列を16進数変換
#                convertHex2MBStrings
#                16進数を日本語文字列に戻す
# * @update        2008/10/27 convertSZSpace2C sjis全角スペースを半角カンマに変換
# * @update        2008/12/04 convertImageSizeを追加
# * @update        2009/01/23 getMobileGUIDを追加
# * @update        2009/01/28 getCarrierByEMail getCarrierCode getMobileSubscribeNumber getMobileGUID をJKZ::JKZMoblileに移動
# * @update        2009/02/18 文字列操作関連サブルーティン名を修正 
# * @update        2009/02/18 日付フォーマットを整えるサブルーティン追加
# * @update        2009/02/19 モジュールのコンパイルを必要なときだけのrequireに変更読み込み
# * @update        2009/03/06 figContentTypeを追加…コンテンツタイプ
# * @update        2009/03/06 publishObj追加。
# * @update        2009/03/12 clearObj追加。
# * @update        2009/07/07 warnTreeLayOut追加
# * @update        2009/07/28 createDirを追加
# * @update        2009/08/03 convertImageSizeを排除
# * @update        2009/08/03 convertByNKFを追加
# * @update        2009/09/07 calculateAgeに月・日チェック処理追加
# * @update        2009/09/08 GetTimeにオプションを追加 13-17
# * @update        2009/09/46 WebUtil::encryptBlowFish WebUtil::decryptBlowFishを追加
# * @update        2010/06/14 cipher decipher関数を追加
# * @update        2010/10/27 convertByNKF文字コード処理を配列に対応
# * @update        2010/12/10 subtractDateTimeAFromDateTimeB関数追加
# * @update        2011/10/31 encodeUriとdecodeUri関数の追加
#********************************************
package MyClass::WebUtil;

use strict;
our $VERSION = '1.2';

use POSIX qw(strftime mktime);
use Unicode::Japanese;
use Unicode::Japanese qw(unijp);
use NKF;


#////////////////////////////////////////////
# 文字列処理関係
#////////////////////////////////////////////

#********************************************
# サニタイズ
#********************************************
sub checkSanitize {
    my $str = shift;
    return "" if $str =~ /[\<|\>|\&|\'|\,|\"]/;#"

    return $str;
}


#********************************************
# URIをエンコードする
#********************************************
sub encodeUri {
    my $str = shift;
    $str    =~ s/([^\w ])/'%' . unpack('H2', $1)/eg;
    $str    =~ tr/ /+/;

    return $str;
}


#********************************************
# URIをデコードする
#********************************************
sub decodeUri {
    my $str = shift;
    $str    =~ tr/+/ /;
    $str    =~ s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2', $1)/eg;

    return $str;
}


#********************************************
# 簡単なescape
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
# 簡単なescapeされた文字をunescape
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
# 改行コードをhtmlの改行タグに変換
#********************************************
sub yenRyenN2br {
    my $str = shift;
    $str =~ s!\r\n!<br />!g;

    return $str;
}


#********************************************
# htmlの改行タグを改行コードに変換
#********************************************
sub br2yenRyenN {
    my $str = shift;
    $str =~ s!<br />!\r\n!g;

    return $str;
}


#********************************************
# htmlの改行タグを改行コードに変換(直前がﾀｸﾞではない場合)
#********************************************
sub yenRyenN2brAfterNoTags { 
    my $str = shift;
    $str =~ s!^[^br />]\r\n!<br \/>!g;

    return $str;
}


#********************************************
# htmlとheadないのﾀｸﾞをエスケープ
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
# スペースを削除
#********************************************
sub trimSpace {
    my $str = shift;
    return "" if !defined $str;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;

    return ($str);
}


#********************************************
# 数字にフォーマットする
#********************************************
sub formatToNumber {
    my $str = shift;
    return "" if !defined $str;
    $str =~ s/\D//g;

    return ($str);
}


#********************************************
# アルファベットにフォーマットする
#********************************************
sub formatToAlphabet {
    my $str = shift;
    $str = "" if !defined $str;
    $str =~ s/[^a-zA-Z]//g;

    return ($str);
}


#********************************************
# 英数字単語にフォーマットする
#********************************************
sub formatToNumberAlphabet {
    my $str = shift;
    $str = "" if !defined $str;
    $str =~ s/[^_a-zA-Z0-9]//g;

    return ($str);
}


#********************************************
# 日付時間のセパレータと長さを整える
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
# @desc     yyyyy mm dd HH MM の時間データをyyyy-mm-dd HH:MMにする
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


#******************************************************
# @desc     DateTimeBからDateTimeAを引き算した結果を返す
# @desc     年は必須。詳細があれば引き算の対象となる
# @param   hashobj
#           {
#               DateTimeA => {
#                   sec  =>  6
#                   min  =>  7
#                   hour =>  8
#                   day  =>  9
#                   mon  => 10   - 1
#                   year => 2004 - 1900 # これは必須
#                   wday => 0
#                   yday => 0
#               },
#               DateTimeB => {
#                   sec  =>  6
#                   min  =>  7
#                   hour =>  8
#                   day  =>  9
#                   mon  => 10   - 1
#                   year => 2004 - 1900 # これは必須
#                   wday => 0
#                   yday => 0
#               },
#           }
# @return  time difference
#******************************************************
sub subtractDateTimeAFromDateTimeB {
    my $datetimeref = shift || return undef;

    # default の時間
    my $datetime_def = {
            DateTimeA => {
                sec  =>  6,
                min  =>  7,
                hour =>  8,
                day  =>  9,
                mon  => (10   - 1),
                year => (2004 - 1900),
                wday => 0,
                yday => 0,
            },
            DateTimeB => {
                sec  =>  6,
                min  =>  7,
                hour =>  8,
                day  =>  9,
                mon  => (10   - 1),
                year => (2004 - 1900),
                wday => 0,
                yday => 0,
            },
       };

    map { $datetime_def->{DateTimeA}->{$_} = $datetimeref->{DateTimeA}->{$_} } keys %{ $datetimeref->{DateTimeA} };
    map { $datetime_def->{DateTimeB}->{$_} = $datetimeref->{DateTimeB}->{$_} } keys %{ $datetimeref->{DateTimeB} };

    my $unixtimeA = mktime($datetime_def->{DateTimeA}->{sec}, $datetime_def->{DateTimeA}->{min}, $datetime_def->{DateTimeA}->{hour}, $datetime_def->{DateTimeA}->{day}, ($datetime_def->{DateTimeA}->{mon} - 1), ($datetime_def->{DateTimeA}->{year} - 1900), $datetime_def->{DateTimeA}->{wday}, $datetime_def->{DateTimeA}->{wday});
    my $unixtimeB = mktime($datetime_def->{DateTimeB}->{sec}, $datetime_def->{DateTimeB}->{min}, $datetime_def->{DateTimeB}->{hour}, $datetime_def->{DateTimeB}->{day}, ($datetime_def->{DateTimeB}->{mon} - 1), ($datetime_def->{DateTimeB}->{year} - 1900), $datetime_def->{DateTimeB}->{wday}, $datetime_def->{DateTimeB}->{wday});

    return ($unixtimeB - $unixtimeA);
}


#********************************************
# 千単位にカンマを挿入
#********************************************
sub insertComma {
    my $int = shift;
    1 while $int =~ s/(.*\d)(\d\d\d)/$1,$2/g;

    return ($int);
}


#********************************************
# 小数点を出す
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
# メルアドチェック
#********************************************
sub Looks_Like_Email {
    my $str = shift;
    return "" if $str =~ /\s|\,/;
    return "" if $str !~ /\b[-\w.]+@[-\w]+\.[-\w]+\b/;

    return ($str =~ /^[^@]+@[^.]+\.[^.]/);
}


#********************************************
# URLチェック 未チェック
#********************************************
sub checkURL {
    my $str = shift;
    my $urlpattern = qq{s?https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+};

    return ($str =~ /^$urlpattern$/);
}


#********************************************
# 全角かなを半角かな変換
#********************************************
sub mbconvertZ2HKana {
    my $str = shift;
    my $tmpstr = Unicode::Japanese->new($str, 'sjis')->get;
    my $ret    = Unicode::Japanese->new($tmpstr)->z2hKana->get;

    return unijp ($ret)->sjis;
}


#********************************************
# 半角かなを全角かな変換
#********************************************
sub mbconvertH2ZKana {
    my $str = shift;
    my $tmpstr = Unicode::Japanese->new($str, 'sjis')->get;
    my $ret    = Unicode::Japanese->new($tmpstr)->h2zKana->get;

    return unijp ($ret)->sjis;
}


#********************************************
# 全て半角変換
#********************************************
sub mbconvertZ2H {
    my $str = shift;
    my $tmpstr = Unicode::Japanese->new($str, 'sjis')->get;
    my $ret    = Unicode::Japanese->new($tmpstr)->z2h->get;

    return unijp ($ret)->sjis;
}


#********************************************
# 全て全角変換
#********************************************
sub mbconvertH2Z {
    my $str = shift;
    my $tmpstr = Unicode::Japanese->new($str, 'sjis')->get;
    my $ret    = Unicode::Japanese->new($tmpstr)->h2z->get;

    return unijp ($ret)->sjis;
}


#********************************************
# utf-8をsjisに変換
#********************************************
sub mbconvertU2S {
    my $str = shift;
    return Unicode::Japanese->new($str)->sjis;
}


#********************************************
# sjisをutf-8に変換
#********************************************
sub mbconvertS2U {
    my $str = shift;
    return Unicode::Japanese->new($str, 'sjis')->get;
}


#********************************************
# sjis全角スペースを半角カンマに変換
#********************************************
sub convertSZSpace2C {
    my $str = shift;
    my $Zspace_sjis = '(?:\x81\x40)';

    $str =~ s/(?:\s|$Zspace_sjis)+/,/go;
    return $str;
}


#********************************************
# 日本語文字列を16進数変換
#********************************************
sub convertMBStrings2Hex {
    my $str = shift || return (undef);
    my $fmt = shift || '%X';

    $str =~ s/(.)/sprintf($fmt, ord($1))/eg;

    return($str);
}


#********************************************
# 16進数を日本語文字列変換
#********************************************
sub convertHex2MBStrings {
    my $hex = shift || return (undef);

    $hex =~ tr/+/ /;
    $hex =~ s/([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex ($1))/eg;

    return ($hex);
}


#******************************************************
# @desc     NKFを使用しての単純な文字コード変換出力
# @param    flag -j,-s,-e,-w
# @param    str
# @return   str
#******************************************************
sub convertByNKF($$) {
    my ($flag, $str) = @_;
    return undef if $flag !~ /^-[j|s|e|w]$/;

    # Modified 2010/10/27 配列に対応
    return ( wantarray ? map { nkf($flag, $_) } @{ $str } : nkf($flag, $str) );
}


#******************************************************
# @desc     sjis文字で半角英数,ひらがな、カタカナだけOK→漢字はNG判定
# @param    str
# @return   str boolean
#******************************************************
sub mbcheckSZkanji {
    my $str = shift;

    my $Hspace                = '[\x20]';                                       # 半角スペース
    my $Zspace_sjis           = '[\x81\x40]';                                   # sjis 全角スペース

    my $oneByte_sjis          = '[\x00-\x7F\xA1-\xDF]';                         # sjis 1バイト
    my $twoByte_sjis          = '(?:[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])'; # sjis 2バイト
    my $sjis                  = '(?:$oneByte_sjis|$twoBytes_sjis)';             # sjis キャラクタ
=pod
    my $ZNumber_sjis          = '(?:\x82[\x4F-\x58])'                           # sjis 全角数字
    my $ZCapitalalphabet_sjis = '(?:\x82[\x60-\x79])';                          # sjis 全角大文字 [Ａ-Ｚ]
    my $ZSmallalphabet_sjis   = '(?:\x82[\x81-\x9A])';                          # sjis 全角小文字 [ａ-ｚ]
    my $Zalphabet_sjis        = '(?:\x82[\x60-\x79\x81-\x9A])';                 # sjis 全角アルファベット [Ａ-Ｚａ-ｚ]
    my $Zhiragana_sjis        = '(?:\x82[\x9F-\xF1])';                          # sjis 全角平仮名 [ぁ-ん]
    my $Zhiragana_ext_sjis    = '(?:\x82[\x9F-\xF1]|\x81[\x4A\x4B\x54\x55])';   # sjis 全角平仮名拡張 [ぁ-ん゛゜ゝゞ]
    my $Zkatakana_sjis        = '(?:\x83[\x40-\x96])';                          # sjis 全角カタカナ [ァ-ヶ]
    my $Zkatakana_ext_sjis    = '(?:\x83[\x40-\x96]|\x81[\x45\x5B\x52\x53])';   # sjis 全角カタカナ拡張 [ァ-ヶ・ーヽヾ]
    my $Hkatakana_sjis        = '[\xA6-\xDF]';                                  # sjis 半角カタカナ
=cut
    my $ZNumber_sjis          = '[\x82][\x4F-\x58]';                            # sjis 全角数字
    my $ZCapitalalphabet_sjis = '[\x82][\x60-\x79]';                            # sjis 全角大文字 [Ａ-Ｚ]
    my $ZSmallalphabet_sjis   = '[\x82][\x81-\x9A]';                            # sjis 全角小文字 [ａ-ｚ]
    my $Zalphabet_sjis        = '[\x82][\x60-\x79\x81-\x9A]';                   # sjis 全角アルファベット [Ａ-Ｚａ-ｚ]
    my $Zhiragana_sjis        = '[\x82][\x9F-\xF1]';                            # sjis 全角平仮名 [ぁ-ん]
    my $Zhiragana_ext_sjis    = '(?:[\x82][\x9F-\xF1]|\x81[\x4A\x4B\x54\x55])'; # sjis 全角平仮名拡張 [ぁ-ん゛゜ゝゞ]
    my $Zkatakana_sjis        = '[\x83][\x40-\x96]';                            # sjis 全角カタカナ [ァ-ヶ]
    my $Zkatakana_ext_sjis    = '[\x83][\x40-\x96]|\x81[\x45\x5B\x52\x53]';     # sjis 全角カタカナ拡張 [ァ-ヶ・ーヽヾ]
    my $Hkatakana_sjis        = '[\xA6-\xDF]';                                  # sjis 半角カタカナ

   ## 半角スペース 全角のスペース  全角大文字小文字アルファベット 全角数字
    my $RegExHspaceZspace              = qr/(?:$Hspace|$Zspace_sjis|$ZNumber_sjis|$Zalphabet_sjis)/;

    my $RegExSZhiraganakatakanaonebyte = qr/\G$sjis*?(?:$oneByte_sjis|$Zhiragana_sjis|$Zkatakana_sjis)/;

    return -1 if $str =~ /$RegExHspaceZspace/go;
    return -1 if $str !~ /$RegExSZhiraganakatakanaonebyte/go;
    return 1;
}


#********************************************
# 文字列をMD5でエンコード
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
# 文字列をMD5でデコード
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
# BlowFishで暗号化
#********************************************
sub encryptBlowFish {
    my @val = @_;

    require Crypt::CBC;
    my $key    = "key value";
    my $cipher = Crypt::CBC->new($key, "Blowfish");

    return ( $cipher->encrypt_hex(join(":", @val)) );
}

#********************************************
# # BlowFishで複合化
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
# @desc     crypt関数で暗号化したい文字列($val)を受け取り、暗号化した文字列を返す
# @param    string, string
#           
# @return   crypted string
#********************************************
sub cipher {
    my ($val) = @_;

    my( $sec, $min, $hour, $day, $mon, $year, $weekday )
                 = localtime( time );
    my( @token ) = ( '0'..'9', 'A'..'Z', 'a'..'z' );
    my $salt     = $token[(time | $$) % scalar(@token)];
    $salt       .= $token[($sec + $min*60 + $hour*60*60) % scalar(@token)];

    return crypt( $val, $salt );
}


#********************************************
# @desc     文字列とcrypt関数で暗号化した文字列から一致するか判定
# @param    string,encrypted string
#           
# @return   boolean
#********************************************
sub decipher {
    my ($passwd1, $passwd2) = @_;

    # 暗号のチェック
    if ( crypt($passwd1, $passwd2) eq $passwd2 ) {
        return 1;
    } else {
        return 0;
    }
}


#******************************************************
# @desc        MD5で引数を計算して引数で指定した長さにする
# @param    $value = MD5で計算する値
#            $length = 指定長さ
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
# @desc        ユーザーにユニークIDを発行する
# @return    UniqueNumber
#******************************************************
sub generateOrderID {
    $ENV{'TZ'} = "Japan";
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $orderid = sprintf("%04d%02d%02d%02d%02d%02d",$year +1900,$mon +1,$mday,$hour,$min,$sec);
    return ($orderid);
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
# その他
#////////////////////////////////////////////


#********************************************
# @access        public 1975年9月25日15時39分5秒
# @param        int        $WhereStr        フォーマットを指定
#                0  yyyy-mm-dd hh:mm   1975-09-25 15:39
#                1  yyyy-mm-dd         1975-09-25
#                2  yyyymmdd           19750925
#                3  yyyymmddhhmm       197509251539
#                4  mmddhhss           0925153905
#                5  yyyymm             197509
#                6  yyyy-mm            1975-09
#                7  yyyymmddhhmmss     19750925153905
#                8  mm月               09月
#                9  yyyy               1975
#                10                    1975-09-05 15:39:09
#                11                    09
#                12                    25
#                13                    15:39:09
#                14                    1539
#                15                    15
#                16                    39
#                17                    09
# @return        指定フォーマットで現在の時間
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
        "%m月%d" . $additional . "日",
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
# @desc        生年月日から年齢を計算
# @param    1975-09-23のフォーマット
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

    ## 年齢の上限値と100歳を設定
    return (1 < $age && $age < 100) ? $age : undef;
#    return (1 < $age)  ? $age : undef;
}


#********************************************
# 時間測定
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
# @desc        拡張子からファイルタイプを取得する・コンテンツタイプから拡張子を取得
# @param    $path/to/$file
# @return    
#******************************************************
sub figContentType {
    my $filename = shift || return undef;

    #*********************************
    # ファイル拡張子とコンテンツタイプ
    # Modified AU/DoCoMo/SoftBankデコメテンプレート用追加2009/04/28
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
    # コンテンツタイプとファイル拡張子
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
# @desc        指定ファイルをオープンして内容を返す
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
# @desc        ディレクトリ作成
# @param    str        $path_to_directory
# @return    boolean (失敗の場合がエラーを出力するから自分でチェック)
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
# @desc        シリアライズして保存
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
# @desc        シリアライズオブジェクトを削除
#******************************************************
sub clearObj {
    my $obj = shift || return undef;
    return(unlink($obj));
}


#******************************************************
# @desc        Cached::Memcachedを利用したオブジェクトを取得
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
# @desc     デバッグ用にWarnのメッセージを出力
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
# @desc        デバッグ用にWarnのメッセージをWEB出力用に
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
# @desc        デバッグ用に木構造のデータを出力
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
