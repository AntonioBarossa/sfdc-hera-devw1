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
        public HDT_WRP_DocumentalPackage(){}
	}

	public class HDT_WRP_DocumentalDeliverPackageRequest{
		public String requestId;
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
        public HDT_WRP_DocumentalDriver(){
            
        }
    }
}