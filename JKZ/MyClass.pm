#******************************************************
# @desc       �t���[�����[�N�̊��N���X
#             �T�C�g��{���������s
#             run.mpl��MyClass   account.mpl��MyClass::JKZAccount
# @package    MyClass
# @access     public
# @author     Iwahase Ryo
# @create     2009/11/02
# @version    1.00
# @update     2009/10/29 �v���O�C���@�\����
#                        mk_accesssor�ǉ�
#                        �A�N�Z�b�T���\�b�h�폜
#                        getCgiQuery getAction
#                        bootstrap���\�b�h�ǉ� 
#             2009/11/05 ���\�b�hnew��initialize�ύX()
#                        run bootstrap dispatch�̏������v���O�������s�R�[�h�Ɉڍs(Plugin�@�\�̓���̖��)
# @update     2009/12/21 connectDB���\�b�h���̃f�o�b�O���[�h�����ǂݍ��ݏ����ǉ�
# @update     2009/12/21 �C���f���g�̃^�u��~�B�X�y�[�X4�ɕύX
# @update     2010/01/07 WebUtil��MyClass::WebUtil
# @update     2010/01/20 action_obj��ǉ�������ς��
# @update     2010/02/02 new�ɂ�memcached���C�j�V�����C�Y�BinitMemcachedFast�͂���Ȃ�A�N�Z�b�T�ɕύX
# @update     2010/03/04 �f�o�b�O�p�Ƀe���v���[�g�t�@�C���𖾎��I�ɑI���ł���悤�ɏC��
# @update     2010/03/29 �J���̃o�[�W�����Ǘ���GitHub�ōs��
#******************************************************

package MyClass;
use 5.008005;
our $VERSION = '1.00';

use strict;

#******************************************************
# MyClass::Plugin  �@�\����
# ���̃N���X��use Class::Component���Ă��邩��APlugin��MyClass::Plugin�ɐݒu����
#******************************************************
use Class::Component;
use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw( cfg config query dbh ) ); ## bless ����hash�̃L�[
__PACKAGE__->load_components(qw/ Autocall::Autoload /);
__PACKAGE__->class_component_reinitialize( reload_plugin => 1 );


use MyClass::UsrWebDB;
use MyClass::JKZHtml;
use MyClass::WebUtil;
use MyClass::JKZSession;
use MyClass::JKZMobile;
use MyClass::JKZLogger;
use MyClass::JKZDB::Member;
use MyClass::JKZDB::TmpltFile;

use Data::Dumper;

use YAML;


#******************************************************
# @access	public
# @desc		�R���X�g���N�^
# @param	
# @return	
#******************************************************
sub new {
    my ($class, $cfg) = @_;

    my $config = $class->setup_configuration($cfg->param('PLUGIN_CONF'));
    my $q      = CGI->new();

    my $action     = defined($q->param('o')) ? $q->param('a') . '_' . $q->param('o') : $q->param('a');

    my $self       = $class->SUPER::new(
        {
            config     => delete $config->{plugin_config},
            cfg        => $cfg,
            query      => $q,
            action     => $action,
            memcached  => undef,
            dbh        => undef,
        }
    );

    $self->config($config);
    $self->setup_plugins();

    return $self;
}


sub run {
}


#******************************************************
# @access    public
# @desc        �g�сE���ϐ��Z�b�g
# @param
# @return    
#******************************************************
sub setAccessUserData {
    my $self  = shift;
    my $agent = MyClass::JKZMobile->new();
    $self->attrAccessUserData("carriercode", $agent->getCarrierCode());
    $self->attrAccessUserData("_sysid", $agent->getDCMGUID());
    $self->attrAccessUserData("subno", $agent->getSubscribeNumber());
    my $xhtmlflag = 1;
    0 < $xhtmlflag ? $self->attrAccessUserData("xhtml", $agent->xhtmlCapable()) : $self->attrAccessUserData("xhtml", undef);

    my $acd = $self->query->param('acd') || '1';
    $self->attrAccessUserData("acd", $acd);
}


sub user_guid {
    my $self = shift;
    $self->{guid} = $self->attrAccessUserData("_sysid");
    return ($self->{guid});
}


sub user_subno {
    my $self = shift;
    $self->{subno} = $self->attrAccessUserData("subno");

    return ($self->{subno});
}


sub user_carriercode {
    my $self = shift;
    $self->{carriercode} = $self->attrAccessUserData("carriercode");
    return ($self->{carriercode});
}


#******************************************************
# @access	
# @desc		�A�N�Z�b�T ����������Βl���Z�b�g
#
#******************************************************
sub action {
	my $self = shift;

	$self->{action} = $_[0] if @_ > 0;

	return $self->{action};
}


#******************************************************
# @desc		get tmplt_id from query or default is 1
# @param	
# @return	
#******************************************************
sub getTmpltID {
    my $self = shift;
    $self->{t} = $self->query->param('t') || 1;

    return $self->{t};
}


#******************************************************
# @desc		set tmplt_id to query
# @param	
# @return	
#******************************************************
sub setTmpltID {
    my ($self, $id) = @_;
    (1 > $id) ? $id = 24 : $id;
    $self->query->param(-name=>"t",-value=>$id);

    return $self->query->param('t');
}


#******************************************************
# @access	private
# @desc		select template code from database table
# @param	
# @return	
#******************************************************
sub _getDBTmpltFile {
    my $self    = shift;
    my $tmpltid = $self->getTmpltID() || 1;

    my $dbh = $self->getDBConnection();
    $self->setDBCharset('SJIS');
    my $myTmpltFile = MyClass::JKZDB::TmpltFile->new($dbh);
    $self->{tmplt}  = $myTmpltFile->fetchTmpltCodeByTmpltID({
                              tmpltm_id => $tmpltid, carrier => $self->attrAccessUserData("carriercode")
                      });

    return $self->{tmplt};
}


#******************************************************
# @access	private
# @desc		select template code from database table by tmplt name
# @param	string $tmplt_name OR action
# @return	
#******************************************************
sub _getDBTmpltFileByName {
    my $self       = shift;
    my $tmplt_name = $_[0] || $self->action();

    my $dbh = $self->getDBConnection();
    $self->setDBCharset('SJIS');
    my $myTmpltFile = MyClass::JKZDB::TmpltFile->new( $dbh, 1 );
=pod
    $self->{tmplt}  = $myTmpltFile->fetchTmpltCodeByTmpltName({
                              tmplt_name => $tmplt_name, carrier => $self->attrAccessUserData("carriercode")
                      });
=cut
   ## �f�o�b�O�p�Ɏw��̎q�e���v���[�g�𖾎��I�Ɏ擾
    $self->{tmplt}  =
        ( defined ($self->_debugTMPLT()) )
        ?
        $myTmpltFile->fetchTmpltCodeByTmpltName({ tmplt_name => $tmplt_name, carrier => $self->attrAccessUserData("carriercode"), debug => 1, tmpltfile_id => $self->_tmpltfile_id() })
        :
        $myTmpltFile->fetchTmpltCodeByTmpltName({ tmplt_name => $tmplt_name, carrier => $self->attrAccessUserData("carriercode") })
        ;
    return $self->{tmplt};
}


#******************************************************
# @access	private
# @desc		select template from directory(tmplt code in a file)
# @param	
# @return	
#******************************************************
sub _getTmpltFile {
    my $self = shift;

    my @carrier = ('docomo', 'softbank', 'au');
    $self->{tmplt} = sprintf("%s/%s/%s", $self->cfg->param('TMPLT_DIR'), $carrier[$self->attrAccessUserData("carriercode")-1], $self->action);

    return $self->{tmplt};
}


sub _debugTMPLT {
    my $self = shift;
    $self->{debugTMPLT} = $self->query->param('debug');
    return $self->{debugTMPLT};
}

sub _tmpltfile_id {
    my $self = shift;
    $self->{tmpltfile_id} = $self->query->param('tf');

    return $self->{tmpltfile_id};
}


#******************************************************
# @access  
# @desc    hook������ǉ�
# @param   
# @param   
# @return  
#******************************************************
sub processHtml {
    my $self = shift;
    my $obj  = shift;
    my $q    = $self->query();

    ## �b�菈�� [ 0 : File system ] [ 1 : DB by ID] [2 : DB by Name ]
    my $TMPLT_BY_DATABASE = $self->cfg->param('DBTMPLT');
    #my $TMPLT_BY_DATABASE = 2;

    my $tmplt = 
        ( 1 == $TMPLT_BY_DATABASE ) ? $self->_getDBTmpltFile()       :
        ( 2 == $TMPLT_BY_DATABASE ) ? $self->_getDBTmpltFileByName() :
                                      $self->_getTmpltFile()         ;

    my $databaseflg = (0 < $TMPLT_BY_DATABASE) ? 1 : 0;

    my $myHtml = MyClass::JKZHtml->new($q, $tmplt, $databaseflg, 0);
    $myHtml->setfile() unless 0 < $databaseflg;

## PLUGIN HOOK ���� BEGIN
	my @hooks = keys %{ $self->class_component_hooks };
	my $hook_regex = qr/If./;

	if ($databaseflg) {
        foreach my $hook (@hooks) {
            if ($tmplt =~ /__(?:$hook_regex$hook)__/) {
                my $tmpobj = $self->run_hook($hook);
                map { $obj->{$_} = $tmpobj->[0]->{$_} } keys %{ $tmpobj->[0] };
            }
        }
    } else {
        my $source_code = $myHtml->load_source_code();
        foreach my $hook (@hooks) {
            if ($source_code =~ /__(?:$hook_regex$hook)__/) {
                my $tmpobj = $self->run_hook($hook);
                map { $obj->{$_} = $tmpobj->[0]->{$_} } keys %{ $tmpobj->[0] };
            }
        }
    }
## PLUGIN HOOK ���� END

    my $benchref = {
        t0 => $self->{t0},
        t1 => $self->setMicrotime("t1"),
    };
    #$obj->{BENCH_TIME} = MyClass::WebUtil::benchmarkMicrotime(2, $benchref);

    $myHtml->convertHtmlTags($obj);
    $myHtml->doPrintTags();
}


sub getFromCache {
    my $self = shift;
    my $key  = shift || return (undef);
    my $memcached = $self->initMemcachedFast();
    my $obj = $memcached->get($key);
    return $obj;
}

sub deleteFromCache {
    my $self = shift;
    my $key  = shift || return (undef);
    my $memcached = $self->initMemcachedFast();
    $memcached->delete($key);
}


#******************************************************
# @access  
# @desc    �G���[�y�[�W�̕\��
#          �G���[�y�[�W�e���v���[�g�͌��ߑł�
#          tmplt_id�̏ꍇ�́F3 tmplt_name�̏ꍇ�Ferror
# @param   
# @return  
#******************************************************
sub printErrorPage {
    my ($self, $msg) = @_;
    my $obj;
    $obj->{ERROR_MSG} = $msg;

    1 == $self->cfg->param('DBTMPLT') ? $self->setTmpltID("3") : $self->action('error');

    #$self->setTmpltID("24");
    #$self->action('error');

    return $obj;
}

sub _myMethodName {
    my @stack = caller(1);
    my $methodname = $stack[3];
    $methodname =~ s{\A .* :: (\w+) \z}{$1}xms;
    return $methodname;
}


#******************************************************
# �T�C�g��URL http:://hp01.1mp.jp (�h���C��)
#******************************************************
sub MAIN_URL {
    my $self = shift;
    return ($self->{MAIN_URL} = $self->cfg->param('MAIN_URL'));
}


#******************************************************
# �T�C�g�g�b�v��URL
#******************************************************
sub MAINURL {
    my $self = shift;

    #$self->{MAINURL} = sprintf("%s/%s", $self->MAIN_URL(), $self->cfg->param('UI_CONTROLER_NAME'));
    $self->{MAINURL} = $self->cfg->param('UI_CONTROLER_NAME');

    ## Modified 2010/01/26
#=pod
    $self->{MAINURL} .= 
            ( 1 == $self->attrAccessUserData("carriercode") ) ? '?guid=ON'
            :
            ( 2 == $self->attrAccessUserData("carriercode") ) ? '?uid=1'
            :
            ( 3 == $self->attrAccessUserData("carriercode") ) ? ''
            :
            ""
           ;
#=cut
=pod
    $self->{MAINURL} .= 
            ( 1 == $self->attrAccessUserData("carriercode") ) ? '/guid=ON'
            :
            ( 2 == $self->attrAccessUserData("carriercode") ) ? '/uid=1'
            :
            ( 3 == $self->attrAccessUserData("carriercode") ) ? ''
            :
            ""
           ;
=cut

 ## SoftBank�����̏ꍇ�͉��L�̃p�����[�^���K�v
 #( 2 == $self->attrAccessUserData("carriercode") ) ? '/mod-perl/run.mpl?uid=1&sid=' . 'E4JI'
    return $self->{MAINURL};
}


#******************************************************
# �����į��URL
#******************************************************
sub MEMBERMAINURL {
   my $self = shift;
my $timenow = MyClass::WebUtil::GetTime(4);
    $self->{MEMBERMAINURL} = sprintf("%s/%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('MEMBER_CONTROLER_NAME'));

    $self->{MEMBERMAINURL} .= 
            ( 1 == $self->attrAccessUserData("carriercode") ) ? '?guid=ON&'
            :
            ( 2 == $self->attrAccessUserData("carriercode") ) ? '?uid=1&sid=&'
            :
            ( 3 == $self->attrAccessUserData("carriercode") ) ? sprintf("?time=%s&", $timenow)
            :
            ""
           ;

    return $self->{MEMBERMAINURL};
}


#******************************************************
# ����̓o�^���֘A��URL
#******************************************************
sub ACCOUNTURL {
   my $self = shift;

    $self->{ACCOUNTURL} = sprintf("%s/%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('ACCOUNT_CONTROLER_NAME'));

    $self->{ACCOUNTURL} .= 
            ( 1 == $self->attrAccessUserData("carriercode") ) ? '?guid=ON&'
            :
            ( 2 == $self->attrAccessUserData("carriercode") ) ? '?uid=1&sid=&'
            :
            ( 3 == $self->attrAccessUserData("carriercode") ) ? '?'
            :
            ""
           ;

    return $self->{ACCOUNTURL};
}


#******************************************************
# �J�[�g�����E���i����������URL
#******************************************************
sub CARTURL {
   my $self = shift;

    $self->{CARTURL} = sprintf("%s/%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('CART_CONTROLER_NAME'));

    $self->{CARTURL} .= 
            ( 1 == $self->attrAccessUserData("carriercode") ) ? '?guid=ON&'
            :
            ( 2 == $self->attrAccessUserData("carriercode") ) ? '?uid=1&'
            :
            ( 3 == $self->attrAccessUserData("carriercode") ) ? '?'
            :
            ""
           ;

    return $self->{CARTURL};
}


#******************************************************#******************************************************#******************************************************#******************************************************#******************************************************
sub PUBLISH_DIR {
    my $self = shift;

    $self->{PUBLISH_DIR} = '/home/vhosts/JKZ/publish';
    return ($self->{PUBLISH_DIR});
    #return ($self->{PUBLISH_DIR} = $self->{cfg}->param('SERIALIZEDOJB_DIR'));
}

#******************************************************
# @access    
# @desc      �f�[�^�x�[�X��ڑ�
#
#******************************************************
sub connectDB {
    my $self = shift;
    $self->{dbh} = MyClass::UsrWebDB::connect();
    ## Modified 2009/12/21
    $self->{dbh}->trace(2, $self->cfg->param('TMP_DIR') . '/DBITrace.log') if 1 == $self->{cfg}->param('DEBUGMODE');
    return $self->{dbh};
}

#******************************************************
# @access    
# @desc      DB�ڑ��n���h��
# @return    database handle
#******************************************************
sub getDBConnection {
    my $self = shift;
    return $self->{dbh};
}

#******************************************************
# @access    
# @desc        disconnect Database
#******************************************************
sub disconnectDB {
    my $self = shift;
    $self->{dbh}->disconnect();
}

#******************************************************
# @access    
# @desc      Set charset fro dbaccess
#******************************************************
sub setDBCharset {
    my ($self, $charset) = @_;
    return ($self->{dbh}->do("set names $charset"));
}

#******************************************************
# @access    Modified 2010/02/02
# @desc      Set charset fro dbaccess
#******************************************************
sub initMemcachedFast {
    my $self = shift;
#    $self->{memcachedfast} = MyClass::UsrWebDB::MemcacheInit();
    $self->{memcached} = MyClass::UsrWebDB::MemcacheInit();
    return $self->{memcached};
}

sub attrAccessUserData {
    my $self = shift;

    return (undef) unless @_;
    $self->{$_[0]} = $_[1] if @_ > 1;

    return ($self->{$_[0]});
}


sub setMicrotime {
    my $self = shift;
    $self->{$_[0]} = MyClass::WebUtil::benchmarkMicrotime(1) if @_;
    return ($self->{$_[0]});
}


sub USE_DBTMPLT {
    my $self = shift;
    return ($self->{DBTMPLT} = $self->cfg->param('DBTMPLT'));
}


sub ERROR_MSG {
    my $self = shift;
    if (@_) {
        my $constant_code = shift;
        return $self->cfg->param($constant_code);
    }

    return;
}


#******************************************************
# @access    public
# @desc        envconf.cfg�ɒl���擾���Ĕz��ŕԂ�
# @param    key
# @return    array
#******************************************************
sub fetchArrayValuesFromConf {
    my $self = shift;
    unless (@_) { return; }

    my $name = shift;
    my @values = split(/,/, $self->cfg->param($name));

    return (@values);
}


#******************************************************
# @access	
# @desc		envconf����CommonUse.xxxM�ɑΉ�����f�[�^���擾
#			envconf�̒萔����f�[�^���擾
#			�z��Ŋi�[����Ă��� �����̒l�ɑΉ�����l��Ԃ�
# @param	$string		envconf���̒萔��
# @param    $integer
# @return   $value
#******************************************************
sub fetchOneValueFromConf {
	my $self = shift;
	unless (@_) { return; }

	my ($name, $value) = @_;
	my $values = $self->{cfg}->param($name);
	my @tmplist = split(/,/, $values);

	return ($tmplist[$value]);
}


sub fetchValuesFromConf {
	my $self = shift;
	unless (@_) { return; }

	my ($name, $defaultvalue) = @_;
	my @values = split(/,/, $self->{cfg}->param($name));

	my $obj;
	no strict ('subs');
	$obj->{Loop . $name . List} = $#values;

	for  (my $i = 0; $i <= $#values; $i++) {
		$obj->{$name . Index}->[$i] = $i;
		$obj->{$name . Value}->[$i] = $values[$i];
		$obj->{$name . 'defaultvalue'}->[$i] = $defaultvalue == $i ? ' selected' : "";
	}

	return $obj;
}


#******************************************************
# @access    
# @desc        �ݒ�t�@�C���̃L�[�������ɑΉ������l���擾
#            �L�[�����݂��Ȃ��ꍇundef��Ԃ�
#
#            �����������̏ꍇ(���X�g�R���e�L�X�g)�͔z��Œl��Ԃ�
#            �������P��̏ꍇ(�X�J���R���e�L�X�g)�̓X�J���Œl��Ԃ�
#
# @param    char    $configrationkey
# @return    char/undef    $configrationvalue
#******************************************************
sub CONFIGURATION_VALUE {
    my $self = shift;

    return undef if 1 > @_;

    my %CONFIGRATIONKEY = $self->cfg->vars();

    return (
        1 == @_
            ?
            ( $self->{CONFIGURATION_VALUE}->{$_[0]} = exists($CONFIGRATIONKEY{$_[0]}) ? $CONFIGRATIONKEY{$_[0]} : undef )
            :
            ( map { $self->{CONFIGURATION_VALUE}->{$_} = ( exists($CONFIGRATIONKEY{$_}) ) ? $CONFIGRATIONKEY{$_} : undef  } @_ )
    );
}



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ����o�^�E�F�؊֘A BEGIN @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#******************************************************
# @access    public
# @desc        �L������̃`�F�b�N�B����ȊO�̏ڍ׏ڍהF�؂�openSessin�ł����Ȃ�tMemberM��guid�J�����ōs���B�V�X�e���Ȃ���_sysid�Ƃ���
# @param    guid�����o�^�̏ꍇ��z�肵�āAsubno�ŔF�؂��s��guid�����o�^�̏ꍇ�����œo�^����B2010/01/07
# @return    
#******************************************************
sub can_login {
    my $self  = shift;

    my $sysid = $self->user_guid();
    my $sql   = "SELECT 1 FROM 1MP.tMemberM WHERE guid=? AND status_flag=?";
    my $dbh   = $self->getDBConnection();

    $self->setDBCharset('SJIS');
    if (!$dbh->selectrow_array($sql, undef, $sysid, 2)) {
        return undef;
    }

    return 1;
=pod
    my $subno = $self->user_subno();
    my $sql   = "SELECT IF(guid IS NULL, 9, 1) FROM 1MP.tMemberM WHERE subno=? AND status_flag=?";
    my $dbh   = $self->getDBConnection();
    my $rc    = $dbh->selectrow_array($sql, undef, $subno, 2);

	1 == $rc ? return 1              :
	9 == $rc ? $self->_regist_guid() :
	           return undef         ;
=cut
}


#******************************************************
# @desc   ����F�؁E�`�F�b�N
# @param
# @return boolean
#******************************************************
sub is_member_loggedin {
    my $self = shift;

    my $sysid = $self->attrAccessUserData("_sysid");
    my $cacheObj = $self->getFromCache("1MPmemberdata:$sysid");

    ## �L���b�V���������ꍇ�͔F��. �F��OK�ł���΃Z�b�V���������{�L���b�V������
    if (!$cacheObj) {
        unless ($self->can_login()) {
    	    return;
        }
        return ( $self->openMemberSession() ? 1 : undef );
    }
    else {
        map { $self->attrAccessUserData($_, $cacheObj->{$_}) } keys %{ $cacheObj };
        return 1;
    }
}


#******************************************************
# @access    public
# @desc        ��������`�F�b�N���ăZ�b�V�������ɃZ�b�g ��cache�Ɋi�[
# @param    sysid(dcmguid, subno)
# @return    
# @author    
#******************************************************
sub openMemberSession {
    my $self  = shift;
    my $sysid = $self->attrAccessUserData("_sysid");

    my $sess_ref;
    if (defined($sysid)) {
        ## ����h�c��ݒ�
        my ($mid, $tmp);
        ### 600�b�������Ƃ��ĉ���f�[�^���X�V
        if (defined ($sess_ref = MyClass::JKZSession->open($sysid, {expire => 3600}))) {
            if (1 == $sess_ref->session_is_valid()) {
                $tmp = $sess_ref->attrData();
                $mid = $sess_ref->attrData("owid");
                $sess_ref->close();
            } else {
                my $obj = $self->_getMemberBaseData();
                if (defined($obj)) {
                    map { $sess_ref->attrData($_, $obj->{$_}) } keys %{$obj};
                    ## �f�[�^�L���b�V���i�[�p
                    $tmp = $sess_ref->attrData();
                    $mid = $sess_ref->attrData("owid");

                    $sess_ref->save_close() if defined($sess_ref);
                }
            }
        } else {
            my $obj = $self->_getMemberBaseData();
            if (defined($obj)) {
                defined($sess_ref = MyClass::JKZSession->open($sysid, {flag => 1}));
                map { $sess_ref->attrData($_, $obj->{$_}) } keys %{$obj};
                ## �f�[�^�L���b�V���i�[�p
                $tmp = $sess_ref->attrData();
                $mid = $sess_ref->attrData("owid");

               #**************************************
               # �Z�b�V���������O�ɉ�����O�C���̃��O
               #**************************************
                my $logger = MyClass::JKZLogger->new({
                    owid	=> $sess_ref->attrData("owid"),
                    guid	=> $sess_ref->attrData("guid"),
                });
                $logger->saveLoginLog();
                $logger->closeLogger();

                $sess_ref->save_close() if defined($sess_ref);
            }
            else {

                return undef;
            }
        }
        my $memcached = $self->initMemcachedFast();
        $memcached->add("1MPmemberdata:$sysid", $tmp, 600);

        map { $self->attrAccessUserData($_, $tmp->{$_}) } keys %{$tmp};

        return 1;
    } else {

        return;
    }
}


#******************************************************
# @access    private
# @desc        ����̊�{���擾 �����p�ɕύX
# @param
# @return    obj
#******************************************************
sub _getMemberBaseData {
    my $self  = shift;
    my $sysid = $self->attrAccessUserData("_sysid");

    my %condition = (
        columns     => [
            'owid', 'status_flag', 'subno', 'guid', 'carrier', 'mobilemailaddress', 'intr_id', 'nickname', 'family_name', 'first_name', 'family_name_kana', 'first_name_kana',
            'personality', 'bloodtype', 'occupation', 'sex', 'year_of_birth', 'month_of_birth','date_of_birth',
            'prefecture', 'zip', 'city', 'street', 'address', 'tel',
            'point', 'adminpoint', 'limitpoint', 'pluspoint','minuspoint', 'registration_date', 'withdraw_date'
        ],
        whereSQL    => 'guid=?',
        placeholder => ["$sysid",],
    );

    my $dbh      = $self->getDBConnection();
    $self->setDBCharset('SJIS');
    my $myMember = MyClass::JKZDB::Member->new($dbh);
    my $obj      = $myMember->getSpecificValuesSQL(\%condition);

    ## ���N���������邠��ꍇ�͔N����v�Z���Ċi�[
	my $birthday = sprintf("%04d-%02d-%02d", $obj->{year_of_birth}, $obj->{month_of_birth}, $obj->{date_of_birth});
	$obj->{age} = MyClass::WebUtil::calculateAge($birthday);

    return if !defined($obj);

    ## �J�[�g�p�ꎞID����U��
    $obj->{_orid} = MyClass::WebUtil::generateOrderID();

    ## ������
    #$obj->{member_status} = $self->fetchOneValueFromConf("MEMBER_STATUS", ((log($obj->{memberstatus_flag}) / log(2))-1));

    return $obj;
}

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ����o�^�E�F�؊֘A END @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



#******************************************************
# @desc        configuration file����ݒ�����擾
# @param    
# @return    
#******************************************************
sub setup_configuration {
    my ($class, $configfile) = @_;

    my $config = YAML::LoadFile($configfile);
    $class->class_component_reinitialize( reload_plugin => 1 );
    my $plugin_config = {};
    for my $plugin (@{ $config->{plugins} }) {
        $plugin_config->{$plugin->{module}} = $plugin->{config} || {};
    }
    $config->{plugin_config} = $plugin_config;

    $config;
}


#******************************************************
# @desc        __PACKAGE__->load_plugins(@plugins); �����̃��\�b�h�s��
# @param    
# @return    
#******************************************************
sub setup_plugins {
    my $self = shift;

    my @plugins;
    for my $plugin (@{ $self->config->{plugins} }) {
        push @plugins, $plugin->{module};
    }

    $self->load_plugins(@plugins);
    #$self->run_hook('plugin.fixup');
}


#******************************************************
# @ �N���X���\�b�h�ł͂Ȃ�
# @desc		check your session
# @return	boolean
#******************************************************
sub checklimit {
	my $check = shift;

	my ($secg,$ming,$hourg,$mdayg,$mong,$yearg,$wdayg,$ydayg,$isdstg) = gmtime(time - 24*60*60);
	my $limit = sprintf("%04d%02d%02d%02d%02d%02d",$yearg +1900,$mong +1,$mdayg,$hourg,$ming,$secg);

	return ($check < $limit ? 0 : 1);
}


#******************************************************
# @access	public
# @desc		�I�y�R�[�h��� �f�o�b�O�F�J���p
# @param	
# @return	
#******************************************************
sub b_terse {
    my $class = shift;
    $class->b_terse_largest();
}

sub b_terse_largest {
    my $package                  = shift;

   eval ("use B::TerseSize;"); die "[error] B::TerseSize IS NOT INSTALLED \n" if $@;

    my ($symbols, $count, $size) = B::TerseSize::package_size($package);
    my ($largest)                =
        sort { $symbols->{$b}{size} <=> $symbols->{$a}{size} }
        grep { exists $symbols->{$_}{count} }
        keys %$symbols;

    print " Total size for $package is $size in $count ops <br />";
    print " Reporting $largest <br />";
    B::TerseSize::CV_walk( 'root', $package . '::' . $largest );

}


1;

__END__
