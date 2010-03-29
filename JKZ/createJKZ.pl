#!/usr/bin/perl

#******************************************************
# @desc		Creates JKZ Framework
#			�Θb�o�[�W����
#			�T�C�g�\���f�B���N�g���𐶐����āA�ݒ�t�@�C��enfconf.cfg��ݒu�B
#			�܂��T�C�g�p�ƊǗ��p�̃R���g���[���[�̐����ƃC���N���[�h�p�X
#			enfconf.cfg�͉��L�f�[�^��ݒ肷��B
#			FRAMEWORK_BASE_D
#			MAIN_URL		
#			CMS_URL			
#			DOCUMENT_ROOT	
#			CMSDOCUMENT_ROOT
#			CONF_DIR		
#			MYLIB_DIR		
#			TMPLT_DIR		
#			CGI_DIR			
#			MODPERL_DIR		
#			UI_CONTROLER	
#			APP_CONTROLER	
#			SENDMAIL_PATH	
# @access	public
# @author	Iwahase Ryo
# @create	2009/01/22
# @update	2009/02/18
# @update	2009/02/27	UI��htdocs/mod-perl/ perl-cgi�ƃv���O�������̑��̃f�B���N�g���t�@�C���̎����ݒu��ǉ�
# @update	2009/02/27	CMS��htdocs/mod-perl/ css js image �A�ƃv���O�������̑��̃f�B���N�g���t�@�C���̎����ݒu��ǉ�
# @update   2009/03/06	SERIALIZEDOBJDIR DL_CONTENTS_DIR��ǉ�
# @update   2009/06/01	�s�v�Ȃ��̂��폜Term::ANSIColor
# @update   2009/06/04	�K�v�Ȓ�`����ђǉ������ɔ����X�V
# @update	2009/06/30	�ݒ�t�@�C���ɍ��ڒǉ��Ȃǂɂ�菈���ǉ�
# @update	2009/12/28  �ݒ�t�@�C���ɍ��ڒǉ��Ȃǂɂ�菈���ǉ�
# @update	2010/03/26  �ݒ�t�@�C���ɍ��ڒǉ��Ȃǂɂ�菈���ǉ�
# @version	1.2
#******************************************************

$|=1;
use strict;

use Cwd;
use File::Path;
use Data::Dumper;

## ��������t�@�C���̃x�[�X
## PLUGINCONF�̃f�t�H���g�͋�t�@�C���i�t�@�C�������݂��K�v �L�ڕ��@��sample.config.yaml���Q�Ɓj
use constant CONFSKEL                  => './dist/envconf.cfg.dist';
use constant OFFICIALSITESKEL          => './dist/officalsite.cfg.dist';
use constant KDDIDEVICENAMELISTSKEL    => './dist/kddi_devicename_list.cfg.dist',
use constant PLUGINCONFSKEL            => './dist/config.yaml.dist',
#use constant UICONTROLERSKEL        => './dist/ui_controler.mpl.dist';
use constant UICONTROLERSKEL           => './dist/run.mpl.dist';
use constant MEMBERCONTROLERSKEL       => './dist/m_run.mpl.dist';
use constant REGISTMEMBERCONTROLERSKEL => './dist/rg.mpl.dist';
use constant ACCOUNTCONTROLERSKEL      => './dist/account.mpl.dist';
use constant CARTCONTROLERSKEL         => './dist/cart.mpl.dist';
use constant CMSCONTROLERSKEL          => './dist/cms_controler.mpl.dist';
use constant UIHTDOCSSKEL              => './dist/site_htdocs.dist';
use constant CMSHTDOCSSKEL             => './dist/cms_htdocs.dist';
use constant CREATETABLESQL            => './dist/createSQLdist.sql';

## get current dir
my $pwd = Cwd::getcwd();
(my $base_path = $pwd) =~ s!JKZ!!;

my $COUNTER = 0;
my $SUCCESS = 3;
my $FAIL = 0;

#**********************************************
# �C���X�g�[���J�n
#**********************************************
while (1) {
	print "\n �t���[�����[�N�̍\�z���J�n���܂��B\n ���E�f�B���N�g���E���C�u�����p�X�̐ݒ�E�ݒu�E�쐬�����܂��B",
			"\n�܂�MySQL�T�[�o�[���N�����Ă��邱�Ƃ���сAMySQL���[�U�[���ݒ肳��Ă��邱�Ƃ��O��ƂȂ�܂��B\n��낵���ł����H [y | n] ";
	my $choice = <STDIN>;
	chomp $choice;
	unless ('y' eq $choice) { last; }

	print "\n �K�{���ڂ�", "(�ԕ����ŕ\��)����܂�<-����Ȃ��B\n";

	#***********************************************
	# �T�C�g�h���C���ƊǗ���ʃh���C��
	#***********************************************
$COUNTER++;
	print "\n$COUNTER\) �T�C�g�̃h���C���������:";
	my $DOMAIN = <STDIN>;
	chomp $DOMAIN;
	unless ($DOMAIN =~ /[-_\.!\~*'\(\)a-zA-Z0-9\;\/?:@&=\+$,%#]+/) {
		print "\n �������T�C�g�h���C��������͂��Ă��������B����: ";
	}

$COUNTER++;
	print "\n$COUNTER\) �Ǘ���ʂ̃h���C���������(�����͂̏ꍇ�̓T�C�g�h���C���{admin�ƂȂ�܂�): ";
	my $CMSDOMAIN = <STDIN>;
	chomp $CMSDOMAIN;

	#***********************************************
	# ���s���[�U�[�F�O���[�v
	#***********************************************
$COUNTER++;
	print "\n$COUNTER\) ���s���[�U�[�̎w�肪����Γ���: ";
	my $USER = <STDIN>;
	chomp $USER;

$COUNTER++;
	print "\n$COUNTER\) ���s�O���[�v�̎w�肪����Γ���: ";
	my $GROUP = <STDIN>;
	chomp $GROUP;

	my $user_group = ($USER and $GROUP) ? $USER . '.' . $GROUP : undef;

	#***********************************************
	# sendmail�̃p�X
	#***********************************************
	my $sendmail_path = `/usr/bin/which sendmail`;
	chomp $sendmail_path;

$COUNTER++;
	print "\n$COUNTER\) sendmail�̃p�X�� $sendmail_path �ł�낵���ł���? [y | n] ";
	$choice = <STDIN>;
	chomp $choice;
	if ('y' ne $choice) {
		print "\n sendmail�̃p�X�����: ";
		$sendmail_path = <STDIN>;
		chomp $sendmail_path;
	}

$COUNTER++;
	print "\n$COUNTER\) SMTP�T�[�o�[����������IP�A�h���X����� [localhost]: ";
	my $smtpserver = <STDIN>;
	chomp $smtpserver;
	$smtpserver ||= 'localhost';


	#***********************************************
	# DataBase�֘A
	#***********************************************
	print "\n MySQLDataBase�̐ݒ���J�n���܂��B";

$COUNTER++;
	my $MySQL = `/usr/bin/which mysql`;
	chomp $MySQL;
	print "\n$COUNTER\) MySQL�v���O������ $MySQL �ł�낵���ł����H[y | n] ";
	$choice = <STDIN>;
	chomp $choice;
	if ('y' ne $choice) {
		print "\n sendmail�̃p�X�����: ";
		$MySQL = <STDIN>;
		chomp $MySQL;
	}


$COUNTER++;
	print "\n$COUNTER\) �f�[�^�x�[�X���[�U�[�������: ";
	my $databaseuser = <STDIN>;
	chomp $databaseuser;

$COUNTER++;
	print "\n$COUNTER\) �f�[�^�x�[�X�p�X���[�h�����: ";
	my $databasepassword = <STDIN>;
	chomp $databasepassword;

$COUNTER++;
	print "\n$COUNTER\) �f�[�^�x�[�X�������: ";
	my $databasename = <STDIN>;
	chomp $databasename;

	#***********************************************
	# Process Check MySQL���N�����Ă��邩
	#***********************************************
	open PS, "/bin/ps -eF |" or die "$!";
	my @PS = <PS>;
	close PS;
	#if (map{ $_ !~ /$MySQL/ } @PS) {
	if (!grep (/$MySQL/, @PS)) {
		print "\n MySQL�T�[�o�[���N�����Ă܂���B�f�[�^�x�[�X����уe�[�u���̐������o���܂���B";
		print "\n MySQL�T�[�o�[���N�����āA�ēx���̃v���O���������s���Ă��������B";
		&take_a_rest();
		last;
		
	}

	my $MySQLCMD = $MySQL . " -p$databasepassword -u$databaseuser $databasename < " . CREATETABLESQL;
	#print "\n", $CMD, "\n";

	#***********************************************
	# �m�����ϐ��ɑ��
	#***********************************************
	## URL
	my $mainurl = 'http://' . $DOMAIN;
	my $cmsurl  = 'http://';
	$cmsurl .= $CMSDOMAIN ? $CMSDOMAIN : $DOMAIN . '/admin'; 

	## set documentroot and documentroot for cms
	my $docroot			= $base_path . $DOMAIN . '/htdocs';
	my $cmsdocroot		= $CMSDOMAIN ? $base_path . $CMSDOMAIN . '/htdocs' : $docroot . '/admin';
	my $confdir			= $pwd . '/conf';
	my $tmpltdir		= $pwd . '/tmplt';
	my $dlcontentsdir	= $pwd . '/dl_contents';
	my $tmpdir			= $pwd . '/tmp';
	my $modulerdir		= $pwd . '/modules';
	my $publisdir		= $pwd . '/publish';
	my $categorylistobj = $publisdir . '/sitecommon/subcategorylist.obj';
	my $top10rankingobj = $publisdir . '/rank/Top10Ranking.obj';
	my $latestcontentsobj = $publisdir . '/newarrival/latestContents.obj';


	## �u������
	my $CONFIGRATION = {
		FRAMEWORK_BASE_DIR				=> $pwd,
		MAIN_URL						=> $mainurl,
		CMS_URL							=> $cmsurl,
		DOCUMENT_ROOT					=> $docroot,
		CMSDOCUMENT_ROOT				=> $cmsdocroot,
		CONF_DIR						=> $confdir,
		MYLIB_DIR						=> $pwd,
		TMPLT_DIR						=> $tmpltdir,
		CGI_DIR							=> '/perl-cgi',
		MODPERL_DIR						=> '/mod-perl',
		DL_CONTENTS_DIR					=> $dlcontentsdir,
		SERIALIZEDOBJ_DIR				=> $publisdir,
		TMP_DIR							=> $tmpdir,
		MODULE_DIR						=> $modulesdir
		UI_CONTROLER					=> 'run.mpl',
		APP_CONTROLER					=> 'app.mpl',
		SITEIMAGE_SCRIPTDATABASE_NAME	=> '/mod-perl/serveSiteImageDB.mpl',
		IMAGE_SCRIPTFILE_NAME			=> '/mod-perl/serveImageFS.mpl',
		IMAGE_SCRIPTDATABASE_NAME		=> '/mod-perl/serveImageDB.mpl',
		FLASH_SCRIPTFILE_NAME			=> '/mod-perl/serveFlashDB.mpl',
		DECOTMPLT_SCRIPTFILE_NAME		=> '/mod-perl/serveDecoTmpltDB.mpl',
		MODIFYMAILADDRESS_SCRIPT_NAME	=> '/mod-perl/modifymailaddress.mpl',
		AFFILIATE_SOCKET_SCRIPT_NAME	=> $pwd . '/extlib/common/affiliate_sock.pl',
		SUBCATEGORYLIST_OBJ				=> $categorylistobj,
		TOP10_RANKING_OBJ				=> $top10rankingobj,
		LASTEST_CONTENTS_OBJ			=> $latestcontentsobj,
		SENDMAIL_PATH					=> $sendmail_path,
		SMTP_SERVER						=> $smtpserver,
		DATABASE_USER					=> $databaseuser,
		DATABASE_PASSWORD				=> $databasepassword,
		DATABASE_NAME					=> $databasename,
		#MEMBER_TABLE
		#MAILCONF_TABLE
		#MAILTYPE_TABLE
	};

	#&progress(10);
	print "\n ���L���e�Ńt���[�����[�N�̍\�z�����܂��B";
	print "\n";
	print "\n���s���[�U�[ ", $USER, "\n���s�O���[�v ", $GROUP if defined $user_group;
	print "\n";
	print map { $_ . "\t" . $CONFIGRATION->{$_} . "\n" } keys %{$CONFIGRATION};


	#***********************************************
	# �f�B���N�g���쐬�J�n
	#***********************************************
	## Create web directories exit this program if any error occur

	my $uicopydir  = UIHTDOCSSKEL . '/*';
	my $cmscopydir = CMSHTDOCSSKEL . '/*';

	eval {
		mkpath([$docroot, $cmsdocroot], 1, 0755);
		system("cp -R $uicopydir $docroot ");
		system("cp -R $cmscopydir $cmsdocroot ");
	};
	if ($@) {
		print "\n Unable to Create ethier $docroot or $cmsdocroot : $@";
		print "\n �f�B���N�g���̃p�[�~�b�V�����A���s�҂̃p�[�~�b�V�������m�F���čēx���s���Ă��������B";
		#print "\n ���̃v���O�������I�����܂��B";
	
		$FAIL++;
	}

	#***********************************************
	# ���s���[�U�[�F�O���[�v�̕ύX
	#***********************************************
	system("/usr/bin/find $base_path -type d -exec chown $user_group {} \\;") if defined $user_group;

	#***********************************************
	# �e�t�@�C���A�v���O�����̌���
	# �e�t�@�C���̐����J�n
	#***********************************************
	my ($conf, $officialsite, $ui_controler, $cms_controler);
	$conf			= $confdir . '/envconf.cfg';
	$officialsite	= $confdir . '/officialsite.cfg';
	$ui_controler	= $docroot . '/run.mpl';
	$cms_controler	= $cmsdocroot . '/app.mpl';

	my @tmpptr = (
		[CONFSKEL, $conf],
		[OFFICIALSITESKEL, $officialsite],
		[UICONTROLERSKEL, $ui_controler],
		[CMSCONTROLERSKEL, $cms_controler],
	);

	foreach my $z (@tmpptr) {
		print $z->[0],"\n", $z->[1],"\n" if -e $z->[0];

		## �x�[�X�f�[�^���擾���A���ɍ��킹���f�[�^�ɒu��������
		local $/;
		local *F;
		open (F, "<". $z->[0] . "\0") or $FAIL++;
		my $skelton = <F>;
		close (F);

		$skelton =~ s{ __(.*?)__ }{ exists ($CONFIGRATION->{$1}) ? $CONFIGRATION->{$1} : ""}gex;

		## �����t�@�C���ɏo�͂��A�Ή��f�B���N�g���ɐݒu
		open (W,">$z->[1]") or $FAIL++;
		print W $skelton;
		close (W);
	}

	system($MySQLCMD);

	print "\n DONE \n";
#	print "\n", $FAIL , '/', $SUCCESS, "���ڂ̎��s�Ɏ��s";
#	last if 0 < $FAIL;

	#***********************************************
	# �f�[�^�x�[�X�̐ݒ�J�n
	# �f�B���N�g���E�t�@�C�������E���ݒ肪�����̂Ƃ�
	#***********************************************
}


sub take_a_rest {
	print "\n";
	sleep 1; print '...';
	sleep 1; print '...';
	sleep 1; print '...';
	print "\n";
}


sub progress {
	my $MAX = shift;
	require Term::ProgressBar;
	#use constant MAX => 20;
	my $prog = Term::ProgressBar->new($MAX);
	for (0..$MAX) {
		sleep 1;
		$prog->update($_);
	}
}

exit();

__END__	
#system("/bin/chown -R $user_group $base_path") if defined $user_group;
=pod
my $cmd = "/bin/chown -R $user_group $base_path";
open CMD, "$cmd |";
my @result = <CMD>;
close CMD;
#my @result = `$cmd`  if defined $user_group;
#foreach (@result) {
#print $_,"\n---\n";
#};
=cut
#print "Unable to change user and group \n" if 256==$?;


sub callback {
	my ($data, $response, $protocol) = @_;
	$finaldata .= $data;
	print "$bars[$counter++]\b";
	$counter = 0 if $counter == scalar (@bars);
}
