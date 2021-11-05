@SuppressWarnings('PMD.ExcessivePublicCount')
public class HDT_WRP_DocumentalRequest{
    public HDT_WRP_DocumentalDeliverPackageRequest deliverPackageRequest;
	
	public class HDT_WRP_DocumentalPackage{
		public List<HDT_WRP_DocumentalDriver> driver;
		public String payloadBase64;

        public HDT_WRP_DocumentalPackage(HDT_WRP_DocumentalPackage input){
            this.driver = new List<HDT_WRP_DocumentalDriver>();
            this.driver.addAll(input.driver);
            this.payloadBase64 = input.payloadBase64;
        }
        public HDT_WRP_DocumentalPackage(List<HDT_WRP_DocumentalDriver> driver,  String payload){
            this.driver = new List<HDT_WRP_DocumentalDriver>();
            this.driver.addAll(driver);
            this.payloadBase64 = payload;
        }
        public HDT_WRP_DocumentalPackage()
        {
            this.driver = new List<HDT_WRP_DocumentalDriver>();
            this.payloadBase64 = '';
        }
	}

	public class HDT_WRP_DocumentalDeliverPackageRequest{
		public String requestId;
        public String mode;
        public String signMode;
        public String objectName;
        public String objectId;
        public HDT_WRP_DocumentalSignInfo signInfo;
		public List<HDT_WRP_DocumentalPackage> sPackage;

        public HDT_WRP_DocumentalDeliverPackageRequest(){
            this.sPackage = new List<HDT_WRP_DocumentalPackage>();
        }
	}

    public class HDT_WRP_DocumentalDriver{
        public String name;
        public String value;
        public HDT_WRP_DocumentalDriver(HDT_WRP_DocumentalDriver input){
            this.name = input.name;
            this.value = input.value;
        }
        public HDT_WRP_DocumentalDriver()
        {
            this.name = '';
            this.value = '';
        }
            
    }
    
    public class HDT_WRP_DocumentalCustomerInfo
    {
        public string vatNumber { get; set; }
        public string fiscalCode { get; set; }
        public string contractCode { get; set; }
        public string creationUrl { get; set; }
        public string emailSubject { get; set; }
        public string email { get; set; }
        public string name { get; set; }
        public string firstName { get; set; }
        public string lastName { get; set; }
        public string dataCreazioneDocumento { get; set; }
        public string dataCaricamentoDocumento { get; set; }
        public string rds { get; set; }
        public string tipoDocumentoStampa { get; set; }
        public string settoreMerceologico { get; set; }
    }

    public class HDT_WRP_DocumentalTemplate
    {
        public string sequence { get; set; }
        public string templateId { get; set; }
    }

    public class HDT_WRP_DocumentalSignInfo
    {
        public String customerEnvironmentId { get; set; }
        public HDT_WRP_DocumentalCustomerInfo customerInfo { get; set; }
        public String pageUrl { get; set; }
        public String status { get; set; }
        public String idCheckConfigurationName { get; set; }
        public String requireIdLookup { get; set; }
        public List<String> senderProvidedNumbers { get; set; }
        public HDT_WRP_DocumentalTemplate template { get; set; }

        public HDT_WRP_DocumentalSignInfo(){
            this.customerInfo = new HDT_WRP_DocumentalCustomerInfo();
            this.template = new HDT_WRP_DocumentalTemplate();
            this.senderProvidedNumbers = new List<String>();
        }
    }
}