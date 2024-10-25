$directory = $PSScriptRoot
$installer = 'orthanc.exe'
$exeSource = Join-Path $directory -ChildPath $installer

$process = Start-Process -FilePath $exeSource -PassThru

Wait-Process -Id $process.Id

$Username = 'admin'
$Password = 'phP@123!'

$filename = 'routing.lua'

$source = Join-Path -Path $directory -ChildPath $filename 

Copy-Item -Path $source -Destination 'C:\Program Files\Orthanc Server\Configuration'

$orthanc = @{
    Name = 'Myorthanc'
    StorageDirectory = 'C:\Orthanc'
    IndexDirectory = 'C:\Orthanc'
    TemporaryDirectory = '/tmp/Orthanc/'
    StorageCompression = $false
    MaximumStorageSize = 0
    MaximumPatientCount = 0
    MaximumStorageMode = 'Recycle'
    MaximumStorageCacheSize = 128
    LuaScripts = @($filename)
    LuaHeartBeatPeriod = 0
    Plugins = @("C:\Program Files\Orthanc Server\Plugins")
    ConcurrentJobs = 2
    JobsEngineThreadsCount = @{ResourceModification = 1}
    HttpServerEnabled = $true
    OrthancExplorerEnabled = $true
    HttpPort = 8042
    HttpDescribeErrors = $true
    HttpCompressionEnabled = $false
    WebDavEnabled = $true
    WebDavDeleteAllowed = $false
    WebDavUploadAllowed = $true
    DicomServerEnabled = $true
    DicomAet = 'ORTHANC'
    DicomCheckCalledAet = $false
    DicomPort = 4242
    DefaultEncoding = 'Latin1'
    AcceptedTransferSyntaxes = @('1.2.840.1.0008.1.*', '1.2.840.10008.1.2', '1.2.840.10008.1.2.1', '1.2.840.10008.1.2.2')
    UnknownSopClassAccepted = $false
    DicomScpTimeout = 30
    RemoteAccessAllowed = $true
    AuthenticationEnabled = $true
    SslEnabled= $false
    SslCertificate = 'certificate.pem'
    SslMinimumProtocolVersion = 4
    SslVerifyPeers = $false
    SslTrustedClientCertificates = 'trustedClientCertificates.pem'
    RegisteredUsers = @{$Username = $Password}
    DicomTlsEnabled = $false
    DicomTlsCertificate = 'orthanc.crt'
    DicomTlsPirvateKey = 'orthanc.key'
    DicomTlsRemoteCertificateRequired = $true
    DicomTlsMinimumProtocolVersion = 0
    DicomTlsCiphersAccepted = @()
    DicomAlwaysAllowEcho = $true
    DicomAlwaysAllowStore = $true
    DicomAlwaysAllowFind = $false
    DicomAlwaysAllowFindWorklist = $false
    DicomAlwaysAllowGet = $false
    DicomAlwaysAllowMove = $false
    DicomCheckModalityHost = $false
    DicomModalities = @{}
    DicomModalitiesInDatabase = $false
    DicomEchoChecksFind = $false
    DicomScuTimeout = 10
    DicomScuPreferredTransferSyntax = '1.2.840.10008.1.2.1'
    DicomThreadsCount = 4
    OrthancPeers = @{U4RAD = @{Url = 'http://13.202.103.243:2002/'
	Username='admin'
	Password='u4rad'}}
    OrthancPeersInDatabase = $false
    HttpProxy = ''
    Httpverbose = $true
    HttpTimeout = 3600
    HttpsverifyPeers = $true
    HttpsCACertificates = 'C:\Program Files\Orthanc Server\Configuration\ca-certificates.crt'
    UserMetadata = @{}
    UserContentType = @{}
    StableAge = 60
    StrictAetComparison = $false
    StoreMD5ForAttachments = $true
    LimitFindResults = 0
    LimitFindInstances = 0
    LogExportedResources = $true
    KeepAlive = $true
    KeepAliveTimeout = 1
    TcpNoDelay = $true
    HttpThreadsCount = 50
    StoreDicom = $true
    DicomAssociationCloseDelay = 5
    QueryRetreiveSize = 100
    CaseSensitivePN = $false
    LoadPrivateDictionary = $true
    Dictionary = @{}
    SynchronousCMove = $true
    JobsHistorySize = 10
    SaveJobs = $true
    OverwriteInstances = $false
    MediaArchiveSize = 5
    StorageAccessOnFind = 'Always'
    MetricsEnabled = $true
    ExecuteLuaEnabled = $false
    RestApiWriteToFileSystemEnabled = $false
    HttpRequestTimeout = 3600
    DefaultPrivateCreator = ''
    StorageCommitmentReportsSize = 100
    TranscodeDicomProtocol = $true
    BuiltinDecoderTranscoderOrder = 'After'
    IngestTranscodingOfUncompressed = $true
    IngestTranscodingOfCompressed = $true
    DicomLossyTranscodingQuality = 90
    SyncStorageArea = $true
    MallocArenaMax = 5
    DeidentifyLogs = $true
    DeidentifyLogsDicomVersion = '2023b'
    MaximumPduLength = 16384
    CheckRevisions = $false
    SynchronousZipStream = $true
    ZipLoaderThreads = 0
    Warnings = @{W001_TagsBeingReadFromStorage = $true
                 W002_InconsistentDicomTagsInDb = $true}
}

$json = $orthanc | ConvertTo-Json 
$json | Set-Content -Path 'C:\Program Files\Orthanc Server\Configuration\orthanc.json'-Encoding UTF8
$serviceName = 'orthanc'
$service = Get-Service -Name $serviceName
if ($service.Status -eq 'Running') {
    Stop-Service -Name $serviceName -Force
}

Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Orthanc\Orthanc Server" -Name "Verbose" -Value 1

Start-Service -Name $serviceName

# Script to add the inbound rules on the system -- Himanshu.
# Add inbound firewall rules for Orthanc
$portHttp = 8042
$portDicom = 4242

# HTTP Inbound Rule
New-NetFirewallRule -DisplayName "Orthanc HTTP" -Direction Inbound -Protocol TCP -LocalPort $portHttp -Action Allow -Profile Any

# DICOM Inbound Rule
New-NetFirewallRule -DisplayName "Orthanc DICOM" -Direction Inbound -Protocol TCP -LocalPort $portDicom -Action Allow -Profile Any

Write-Host "Inbound firewall rules for Orthanc have been added."

# End of Inbound rule logic.

$service = Get-Service -Name $serviceName
Write-Host 'Installation Finished'
