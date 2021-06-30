import { LightningElement, api, track } from 'lwc';
import getInstanceWrapAddressObject from '@salesforce/apex/HDT_UTL_ServicePoint.getInstanceWrapAddressObject';
import getIndirizzo from '@salesforce/apex/HDT_LC_AdvancedSearch.getIndirizzo';
import getIndirizzoFornitura from '@salesforce/apex/HDT_LC_AdvancedSearch.getIndirizzoFornitura';
import getAddressFromAccount from '@salesforce/apex/HDT_LC_AdvancedSearch.getAddressFromAccount';
import getAddressComune from '@salesforce/apex/HDT_WS_HerokuAddressSearch.callServiceCom';
import getAddressInd from '@salesforce/apex/HDT_WS_HerokuAddressSearch.callServiceInd';
import getAddressRev from '@salesforce/apex/HDT_WS_HerokuAddressSearch.callServiceVer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class hdtTargetObjectAddressFields extends LightningElement {
    @api objectapiname;
    @api fieldsAddressObject=[];
    @api wrapObjectInput= [];
    @api wrapAddressObject;
    @api fieldsDataReq;
    @api selectedservicepoint;
    @api servicePointRetrievedData ;
    @api herokuAddressServiceData;
    hasAddressBeenVerified = false;
    @track submitedAddressFields = {};
    verifyDisabledOnUpdate = true;
    verifyFieldsAddressDisabled= true;
    disableVerifIndiButton = true;
    @api recordtype;
    @api headertoshow;
    @api checkBoxFieldValue = false;
    @api textFieldValue;
    @api theRecord = {};
    @api stato = 'ITALIA';
    @api provincia;
    @api comune;
    @api cap;
    @api via;
    @api civico;
    @api estensCivico;
    @api codComuneSAP;
    @api codStradarioSAP;
    @api CodiceLocalita;
    @api Localita;
    @api IndEstero = false ;
    @api aprimodal = false;
    @api flagVerificato =false;
    @track openmodel = false;
    tableData = [];
    dataAccountAddress=[];
    dataAddressFornitura=[];
    columnsFornitura=[];
    tableColumnsFornitura = [];
    tableDataFornitura = [];
    tableColumns = [];
    isLoaded = false;
    columns = [];
    originalData = [];
    originalDataFornitura = [];
    pages = [];
    pagesFornitura=[];
    preloading = false;
    @track currentPage = 0;
    @track currentPageFornitura = 0;
    totalPage = 0;
    totalPageFornitura = 0;
    @api accountid;
    @track filterInputWordFornitura = null;
    @track filterInputWord = null;
    confirmButtonDisabled=true;
    rowToSend=[];
    disableCheckBoxFornitura=false;
    disableCheckBoxFatturazione=false;
    booleanForm=false;
    disableStato=false;
    disableProvincia=false;
    disableCap=false;
    disableCodComuneSap=false;
    disableCodViaSap=false;
    visibleCopiaResidenza=false;
    visibleSelezioneIndirizzi=false;
    disableFlagVerificato=false;
    boolProvincia=false;
    boolCap = false;
    boolComune = false;
    boolVia = false;
    boolCivico = false;
    statusCodeComune='';
    
    

    handleSelectedValue(event) {
    console.log('handleSelectedValue - event ' +JSON.stringify(event.detail));
    console.log('handleSelectedValue - rowtosend****' + JSON.stringify(this.rowToSend));
    this.template.querySelector('c-hdt-selection-address-response').closeForm();
    if(event.detail['city1'] != null){
        this.comune=event.detail['city1'];
        this.theRecord['Comune']= event.detail['city1'];
    }
    if(event.detail['cityCode'] != null){
        this.codComuneSAP=event.detail['cityCode'];
        this.theRecord['Codice Comune SAP']= event.detail['cityCode'];
    }
    if(event.detail['region'] != null){
        this.provincia=event.detail['region'];
        this.theRecord['Provincia']= event.detail['region'];
    }
    if(event.detail['street'] != null){
        this.via=event.detail['street'];
        this.theRecord['Via']= event.detail['Via'];
    }
    if(event.detail['streetCode'] != null){
        console.log('entra in streetCode ' + JSON.stringify(event.detail['streetCode']));
        this.codStradarioSAP=event.detail['streetCode'];
        this.theRecord['codStradarioSAP']= event.detail['streetCode'];
    }
    if(event.detail['cityPName'] != null){
        console.log('entra in Localita ' + JSON.stringify(event.detail['cityPName']));
        this.localita=event.detail['cityPName'];
        this.theRecord['Localita']= event.detail['cityPName'];
    }
    if(event.detail['cityPCode'] != null){
        console.log('entra in Localita ' + JSON.stringify(event.detail['cityPCode']));
        this.codicelocalita=event.detail['cityPCode'];
        this.theRecord['Codice Localita']= event.detail['cityPCode'];
    }
    if(this.codComuneSAP != null && this.codStradarioSAP != null && this.civico != null){
        this.disableVerifIndiButton = false;
    }
    else{
        this.disableVerifIndiButton = true;
    }
    console.log('handleSelectedValue theRecord : ' + JSON.stringify(this.theRecord));

    }

    handleChange(event) {
        this.comune = event.detail.value;
        this.autocomplete= 'false';
    }



handleAddressFromAccount()
{
    console.log(' getAddressFromAccount START****');
	this.preloading = true;
    console.log('accountiD getAddressFromAccount ****' + JSON.stringify(this.accountid));

	getAddressFromAccount({accountId:this.accountid}).then(data =>
	{
        console.log('data getAddressFromAccount ****' + JSON.stringify(data));
		if(data!= undefined){

            this.via= data['Via'];
            this.civico= data['Civico'];
            this.comune=data['Comune'];		
            this.provincia=data['Provincia'];
            this.cap=data['CAP'];
            this.stato=data['Stato'];
			this.estensCivico=data['Est.Civico'];
            this.codComuneSAP='';
            this.codStradarioSAP='';
            this.flagVerificato=true;

            this.theRecord['Via']= data['Via'];
            this.theRecord['Civico']= data['Civico'];
            this.theRecord['Comune']= data['Comune'];
            this.theRecord['Provincia']= data['Provincia'];
            this.theRecord['CAP']= data['CAP'];
            this.theRecord['Stato']= data['Stato'];
            this.theRecord['Estens.Civico']= data['Est.Civico'];
            this.theRecord['Codice Comune SAP']= '';
            this.theRecord['Codice Via Stradario SAP']= '';
            this.theRecord['Flag Verificato']= true;
            

        }
    });
	
	this.preloading = false;
    console.log(' getAddressFromAccount END****');
}

@api
handleAddressValuesIfSap(servicePointRetrievedData){
    console.log('handleAddressValuesIfSap START');
    console.log('handleAddressValuesIfSap servicePointRetrievedData :' + JSON.stringify(servicePointRetrievedData));
    
    Object.keys(servicePointRetrievedData).forEach(key=>{
        switch(key){
            case 'SupplyCountry__c':
                this.stato = servicePointRetrievedData[key] ;
                this.theRecord['Stato'] = servicePointRetrievedData[key] ;
            break;
            case 'SupplyCity__c':
                this.comune= servicePointRetrievedData[key] ;
                this.theRecord['Comune'] = servicePointRetrievedData[key] ;
            break;
            case 'SupplyProvince__c':
                this.provincia= servicePointRetrievedData[key] ;
                this.theRecord['Provincia'] = servicePointRetrievedData[key] ;
            break;
            case 'SupplyPostalCode__c':
                this.cap = servicePointRetrievedData[key] ;
                this.theRecord['CAP'] = servicePointRetrievedData[key] ;
            break;
            case 'SupplyStreet__c':
                this.via = servicePointRetrievedData[key] ;
                this.theRecord['Via'] = servicePointRetrievedData[key] ;
            break;
            case 'SupplyStreetNumberExtension__c':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.estensCivico = servicePointRetrievedData[key] ;
                this.theRecord['Estens.Civico'] = servicePointRetrievedData[key] ;
            break;
            case 'SupplyStreetNumber__c':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.civico = servicePointRetrievedData[key] ;
                this.theRecord['Civico'] = servicePointRetrievedData[key] ;
            break;
            case 'SupplySAPCityCode__c':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.codComuneSAP = servicePointRetrievedData[key] ;
                this.theRecord['Codice Comune SAP'] = servicePointRetrievedData[key] ;
            break;
            case 'SupplySAPStreetCode__c':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.codStradarioSAP = servicePointRetrievedData[key] ;
                this.theRecord['Codice Stradario SAP'] = servicePointRetrievedData[key] ;
            break;
            case 'SupplyIsAddressVerified__c':

            console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
            this.flagVerificato = servicePointRetrievedData[key] ;
            this.theRecord['Flag Verificato'] = servicePointRetrievedData[key] ;

            break;
            case 'SupplyPlace__c':

            this.CodiceLocalita = servicePointRetrievedData[key] ;
            this.theRecord['Codice Localita'] = servicePointRetrievedData[key] ;

            break;
            case 'SupplyPlaceCode__c':

            this.Localita = servicePointRetrievedData[key] ;
            this.theRecord['Localita'] = servicePointRetrievedData[key] ;

            break;

        }
        this.flagVerificato=true;
        this.theRecord['Flag Verificato'] = this.FlagVerificato;
        
    });
    console.log('handleAddressValues END ');
}


    alert(title,msg,variant){
    const event = ShowToastEvent({
        title: title,
        message:  msg,
        variant: variant
    });
    dispatchEvent(event);
}

    handleConfirm(){
        console.log('entra in handleconfirm');
        console.log(' rowToSend**************'+JSON.stringify(this.rowToSend));
        this.preloading = true;
        this.closeModal();
		let data;
        let dataFornitura ;

        if(this.rowToSend['Indirizzo']!=undefined){
            data = this.rowToSend['Indirizzo'].split(",");
            console.log('data after rowToSend**************'+JSON.stringify(data));
        }
        if(this.rowToSend['IndirizzoFornitura']!=undefined){
            dataFornitura = this.rowToSend['IndirizzoFornitura'].split(",");
            console.log('dataFornitura after rowToSend**************'+JSON.stringify(data));
        }

       /* else if(this.rowToSend['Indirizzo Fornitura']!=undefined)
        {
            console.log(' rowToSend**************'+JSON.stringify(this.rowToSend['Indirizzo Fornitura']));
            data = this.rowToSend[''].split(",");
            console.log('data after rowToSend**************'+JSON.stringify(data));

        }*/

     
         if(data!= undefined){
             console.log('entra in data != undefined : ' + JSON.stringify(data));
                this.via= data[1];
                this.civico= data[2];
                this.estensCivico= data[4];
                this.comune=data[0]; 
                this.provincia=data[3];
                this.cap=data[6];
                this.stato=data[5];

                this.codComuneSAP = data[7] !== undefined ? data[7] : '';
                this.codStradarioSAP = data[8] !== undefined ? data[8] : '';
               // this.IndEstero = data[10] !== undefined ? data[10] : false;

                this.disableVerifIndiButton= false;
                data=[];
         }
         if(dataFornitura!= undefined){
            console.log('entra in dataFornitura != undefined : '+ JSON.stringify(dataFornitura));
            this.via= dataFornitura[1];
            this.civico= dataFornitura[2];
            this.estensCivico= dataFornitura[4];
            this.comune=dataFornitura[0]; 
            this.provincia=dataFornitura[3];
            this.cap=dataFornitura[6];
            this.stato=dataFornitura[5];

            this.codComuneSAP = dataFornitura[7] !== undefined ? dataFornitura[7] : '';
            this.codStradarioSAP = dataFornitura[8] !== undefined ? dataFornitura[8] : '';
           // this.IndEstero = dataFornitura[10] !== undefined ? dataFornitura[10] : false;

            this.disableVerifIndiButton= false;
            dataFornitura=[];
         }


            this.theRecord['Via']= this.via;
            this.theRecord['Civico']= this.civico;
            this.theRecord['Estens.Civico']= this.estensCivico;
            this.theRecord['Comune']= this.comune;
            this.theRecord['Provincia']= this.provincia;
            this.theRecord['CAP']= this.cap;
            this.theRecord['Stato']= this.stato;

            this.theRecord['CodiceComuneSAP'] = this.codComuneSAP;
            this.theRecord['CodiceViaStradarioSAP'] = this.codStradarioSAP;
            this.theRecord['IndirizzoEstero'] = this.IndEstero;
            this.theRecord['Flag Verificato'] = this.FlagVerificato;

            

        this.preloading = false;
        console.log(' THERECORD**************'+JSON.stringify(this.theRecord));
        console.log('esce da handleconfirm');

    }

    getSelectedServicePoint(event){
        console.log('getSelectedServicePoint START');
  
        
        this.disableCheckBoxFornitura=true;
        this.preloading = true;
        let selectedRows = event.detail.selectedRows;
        this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        console.log('rowToSend ******' + JSON.stringify(this.rowToSend));
        this.preloading = false;
        this.flagVerificato=true;
        this.theRecord['Flag Verificato']= true;
        console.log('getSelectedServicePoint END');
    }
    
    getSelectedAddress(event){
        console.log('getSelectedAddress START');

        this.disableCheckBoxFatturazione=true;
        this.preloading = true;
        let selectedRows = event.detail.selectedRows;
        this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        console.log('rowToSend ******' + JSON.stringify(this.rowToSend));
        this.preloading = false;
        this.flagVerificato=true;
        this.theRecord['Flag Verificato']= true;
        console.log('getSelectedAddress END');
    }


    handleFilterDataTableFornitura(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.originalDataFornitura));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    Object.values(row).forEach(v => {
                        if (v !== undefined && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase())  !== -1 ) ) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })
            }
            self.createTableFornitura(data); // redesign table
            self.currentPageFornitura = 0; // reset page
        }, 1000);
    }

    handleFilterDataTable(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.originalData));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    Object.values(row).forEach(v => {
                        if (v !== undefined && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase())  !== -1 ) ) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })
            }
            self.createTable(data); // redesign table
            self.currentPage = 0; // reset page
        }, 1000);
    }

    @api
    submitIndirizzo(){
        this.preloading = true;
            console.log('AccountId *******************'+ JSON.stringify(this.accountid));
            this.columns = [
                {label: '', fieldName: 'Indirizzo', type: 'Text'},
           ];
            let dataForTable ='';
            getIndirizzo({accountId:this.accountid}).then(data =>{

                console.log('****getIndirizzo: '+  JSON.stringify(data));
                data.forEach(element=>{
           
                    console.log('****element: '+  JSON.stringify(element));
                    if(element[' '].Comune != undefined){
                        dataForTable += element[' '].Comune;
                        if(element[' '].Comune!=', '){
                            console.log('entra in Comune else : ');
                            dataForTable+=',';
                        }
                    }
                    if(element[' '].Via != undefined){
                        dataForTable += element[' '].Via;
                        if(element[' '].Via!=', '){
                            console.log('entra in Via else : ');
                            dataForTable+=',';
                        }
                    }
                    if(element[' '].Civico != undefined){
                        dataForTable += element[' '].Civico;
                        if(element[' '].Civico!=', '){
                            console.log('entra in civico else : ');
                            dataForTable+=',';
                        }
                    }
                    if(element[' '].Provincia != undefined){
                        dataForTable += element[' '].Provincia;
                        if(element[' '].Provincia!=', '){
                            console.log('entra in Provincia else : ');
                            dataForTable+=',';
                        }
                    }
                    if(element[' '].EstensCivico != undefined){
                        dataForTable += element[' '].EstensCivico;
                        if(element[' '].EstensCivico!=', '){
                            console.log('entra in EstensCivico else : ');
                            dataForTable+=',';
                        }
                    }
                    if(element[' '].Stato != undefined){
                        dataForTable += element[' '].Stato;
                        if(element[' '].Stato!=', '){
                            console.log('entra in Stato else : ');
                            dataForTable+=',';
                        }
                    }
                    if(element[' '].CAP != undefined){
                        dataForTable += element[' '].CAP ;
                        if(element[' '].CAP!=', '){
                            console.log('entra in CAP else : ');
                            dataForTable+=',';
                        }
                    }
                    if(element[' '].CodiceComuneSAP != undefined){
                        dataForTable += element[' '].CodiceComuneSAP;
                        if(element[' '].CodiceComuneSAP!=', '){
                            console.log('entra in CodiceComuneSAP else : ');
                            dataForTable+=',';
                        }
                    }
                    if(element[' '].CodiceViaStradarioSAP != undefined){
                        dataForTable += element[' '].CodiceViaStradarioSAP;
                        if(element[' '].CodiceViaStradarioSAP!=', '){
                            console.log('entra in CodiceViaStradarioSAP else : ');
                            dataForTable+=' ';
                        }
                    }


                   this.dataAccountAddress = [{
    
                    'Indirizzo': dataForTable
                    
                }];

                   
                    console.log('dataForTable ' + dataForTable );
                }); 
                this.preloading = false;
                if (data.length > 0) {
                    this.originalData = JSON.parse(JSON.stringify(dataForTable));
                   // this.createTable(dataForTable);
                   // this.formatTableHeaderColumns(dataForTable);
                    this.openmodel = true;
                    this.isLoaded = true;
                    console.log('getIndirizzo pages: '+ JSON.stringify(this.pages));
                    console.log('getIndirizzo tableData: '+ JSON.stringify(this.tableData));

                } else {
                    this.alert('Dati tabella','Nessun record trovato','warn')
                    this.tableData=[];
                    this.tableData = data;
                }
            });
            
            getIndirizzoFornitura({accountId:this.accountid}).then(data =>{

                console.log('****getIndirizzoFornitura: ', JSON.stringify(data));
                this.preloading = false;
                this.dataAddressFornitura=[];
                let dataForTableForn ='';
                
                this.columnsFornitura = [
                    {label: '', fieldName: 'IndirizzoFornitura', type: 'Text'},
               ];
                data.forEach(element=>{
                    dataForTableForn ='';
                    console.log('****element INDIRIZZOFORNITURA: '+  JSON.stringify(element['INDIRIZZOFORNITURA'].CAP));
                    if(element['INDIRIZZOFORNITURA'].Comune != undefined){
                        dataForTableForn += element['INDIRIZZOFORNITURA'].Comune + ',';
                    }
                    if(element['INDIRIZZOFORNITURA'].Via != undefined){
                        dataForTableForn += element['INDIRIZZOFORNITURA'].Via + ',';
                    }
                    if(element['INDIRIZZOFORNITURA'].Civico != undefined){
                        dataForTableForn += element['INDIRIZZOFORNITURA'].Civico + ',';
                    }
                    if(element['INDIRIZZOFORNITURA'].Provincia != undefined){
                        dataForTableForn += element['INDIRIZZOFORNITURA'].Provincia+ ',';
                    }
                    if(element['INDIRIZZOFORNITURA'].EstensCivico != undefined){
                        dataForTableForn += element['INDIRIZZOFORNITURA'].EstensCivico + ',';
                    }
                    if(element['INDIRIZZOFORNITURA'].Stato != undefined){
                        dataForTableForn += element['INDIRIZZOFORNITURA'].Stato + ',';
                    }
                    if(element['INDIRIZZOFORNITURA'].CAP != undefined){
                        dataForTableForn += element['INDIRIZZOFORNITURA'].CAP + ',';
                    }
                    if(element['INDIRIZZOFORNITURA'].CodiceComuneSAP != undefined){
                        dataForTableForn += element['INDIRIZZOFORNITURA'].CodiceComuneSAP + ',';
                    }
                    if(element['INDIRIZZOFORNITURA'].CodiceViaStradarioSAP != undefined){
                        dataForTableForn += element['INDIRIZZOFORNITURA'].CodiceViaStradarioSAP;
                    }

                    console.log('dataForTableForn lenght : ' + dataForTableForn.length);

                    console.log('dataForTable ' + dataForTableForn );

                    this.dataAddressFornitura.push({'IndirizzoFornitura': dataForTableForn});                    
                    
                }); 
                
                if (data.length > 0) {
                    this.originalDataFornitura = JSON.parse(JSON.stringify(this.dataAddressFornitura));
                    this.createTableFornitura(this.dataAddressFornitura);
                    this.formatTableHeaderColumnsFornitura(this.dataAddressFornitura);
                    this.openmodel = true;
                    this.isLoaded = true;
                    console.log('getIndirizzoFornitura pages: '+ JSON.stringify(this.pagesFornitura));
                    console.log('tableDataFornitura******'+ JSON.stringify(this.tableDataFornitura));
                } else {
                    this.alert('Dati tabella','Nessun record trovato','warn')
                    this.tableDataFornitura=[];
                    this.tableDataFornitura = data;
                }
            });
       
        
    }

     /**
     * Create header for Data-Table header with original data
     */
      formatTableHeaderColumns(rowData) {
        let columns = [];
        this.tableColumns = [];
        rowData.forEach(row => {
            let keys = Object.keys(row);
            columns = columns.concat(keys);
        });
        let columnsUniq = [...new Set(columns)];
        columnsUniq.forEach(field => this.tableColumns.push({label: field, fieldName: field}));
    }

    formatTableHeaderColumnsFornitura(rowData) {
        let columns = [];
        this.tableColumnsFornitura = [];
        rowData.forEach(row => {
            let keys = Object.keys(row);
            columns = columns.concat(keys);
        });
        let columnsUniq = [...new Set(columns)];
        columnsUniq.forEach(field => this.tableColumnsFornitura.push({label: field, fieldName: field}));
    }

    /**
     * Create Data-Table
     */
    createTable(data) {
        console.log('data table ' + JSON.stringify(data));
        let i, j, temporary, chunk = 5;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPage = this.pages.length;
        this.reLoadTable();
    }

    createTableFornitura(data) {
        console.log('data table fornitura ' + JSON.stringify(data));

        let i, j, temporary, chunk = 5;
        this.pagesFornitura = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pagesFornitura.push(temporary);
        }
        this.totalPageFornitura = this.pagesFornitura.length;
        this.reLoadTableFornitura();
    }

    reLoadTable() {
        this.tableData=[];
        this.tableData = this.pages[this.currentPage];

        console.log('currentPage********'+ this.currentPage);
        console.log('tableData********'+ JSON.stringify(this.tableData));

    }

    reLoadTableFornitura() {
        this.tableDataFornitura=[];
        this.tableDataFornitura = this.pagesFornitura[this.currentPageFornitura];

        console.log('tableDataFornitura********'+ JSON.stringify(this.tableDataFornitura));

    }

    nextPage() {
        if (this.currentPage < this.totalPage) this.currentPage += 1;
        this.reLoadTable();
    }

    previousPage() {
        if (this.currentPage > 1) this.currentPage-= 1 ;
        this.reLoadTable();
    }

    nextPageFornitura() {
        if (this.currentPageFornitura < this.totalPageFornitura - 1) this.currentPageFornitura++;
        this.reLoadTableFornitura();
    }

    previousPageFornitura() {
        if (this.currentPageFornitura > 0) this.currentPageFornitura--;
        this.reLoadTableFornitura();
    }

    get getCurrentPage() {
        if (this.totalPage===0) return 0;
        return this.currentPage + 1;
    }

    get getCurrentPageFornitura() {
        if (this.totalPageFornitura===0) return 0;
        return this.currentPageFornitura + 1;
    }
    
    openmodal() {
        this.openmodel = true;
    }
    closeModal() {
        this.openmodel = false;
    } 

    submitAddressModal(){
        this.openMod();
    }


@api
handleAddressValues(servicePointRetrievedData){
    console.log('handleAddressValues START - servicePointRetrievedData :' + JSON.stringify(servicePointRetrievedData));
    Object.keys(servicePointRetrievedData).forEach(key=>{
        switch(key){
            case 'Stato':
                this.stato = servicePointRetrievedData[key] ;
                this.theRecord['Stato'] = servicePointRetrievedData[key] ;
            break;
            case 'Provincia':
                this.provincia= servicePointRetrievedData[key] ;
                this.theRecord['Provincia'] = servicePointRetrievedData[key] ;
            break;
            case 'Comune':
                this.comune= servicePointRetrievedData[key] ;
                this.theRecord['Comune'] = servicePointRetrievedData[key] ;
            break;
            case 'CAP':
                this.cap = servicePointRetrievedData[key] ;
                this.theRecord['CAP'] = servicePointRetrievedData[key] ;
            break;
            case 'Via':
                this.via = servicePointRetrievedData[key] ;
                this.theRecord['Via'] = servicePointRetrievedData[key] ;
            break;
            case 'Civico':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.civico = servicePointRetrievedData[key] ;
                this.theRecord['Civico'] = servicePointRetrievedData[key] ;
            break;
            case 'EstensCivico':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.estensCivico = servicePointRetrievedData[key] ;
                this.theRecord['Estens.Civico'] = servicePointRetrievedData[key] ;
            break;
            case 'CodiceComuneSAP':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.codComuneSAP = servicePointRetrievedData[key] ;
                this.theRecord['Codice Comune SAP'] = servicePointRetrievedData[key] ;
            break;
            case 'CodiceViaStradarioSAP':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.codStradarioSAP = servicePointRetrievedData[key] ;
                this.theRecord['Codice Via Stradario SAP'] = servicePointRetrievedData[key] ;
            break;
            case 'IndirizzoEstero':
                this.IndEstero = servicePointRetrievedData[key] ;
                this.theRecord['Indirizzo Estero'] = this.IndEstero;

            break;
            case 'FlagVerificato':

                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.flagVerificato = servicePointRetrievedData[key] ;
                this.theRecord['Flag Verificato'] = this.flagVerificato;

            break;
        }

    });
    console.log('handleAddressValues END ');
}


@api
handleCheckBoxChange(event){
    console.log('event detail : ******++'+ JSON.stringify(event.target.name));
    
        this.checkBoxFieldValue = event.target.checked;
        this.theRecord[event.target.name] = event.target.checked;
        console.log(event.target.name + ' now is set to ' + event.target.checked); 
        switch(event.target.name){
            case 'Indirizzo Estero':
                console.log('entra in indirizzo estero case');
                this.IndEstero = event.target.checked;
                if(event.target.checked==true){
                    this.stato='ESTERO';
                }else{
                    this.stato='ITALIA';
                }
                this.flagVerificatoFalse();
                break;
            case 'Flag Verificato':
                console.log('entra in Flag Verificato case');

                this.flagVerificato =  event.target.checked;
                break;
        }

        this.disableFieldByIndEstero();



        
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
}

flagVerificatoFalse(){
    console.log('flagVerificatoFalse START');
    this.theRecord['Flag Verificato'] = false;

    this.flagVerificato = false;
    console.log('Flag Verificato : '+JSON.stringify(this.flagVerificato));
    console.log('flagVerificatoFalse END');
}

@api
disableFieldByIndEstero(){

    console.log('disableFieldByIndEstero START');
    if(this.IndEstero === false ){
        console.log('entra in indEstero false');
        this.disableStato=true;
        this.disableProvincia=true;
        this.disableCap=true;
        this.disableCodComuneSap=true;
        this.disableCodViaSap=true;
       
        this.boolProvincia=false;
        this.boolCap = false;
        this.boolComune = false;
        this.boolVia = false;
        this.boolCivico = false;

    }
    if(this.IndEstero === true)
    {
        console.log('entra in indEstero true');
        this.disableStato=false;
        this.disableProvincia=false;
        this.disableCap=false;
        this.disableCodComuneSap=false;
        this.disableCodViaSap=false;

        this.boolProvincia=true;
        this.boolCap = true;
        this.boolComune = true;
        this.boolVia = true;
        this.boolCivico = true;
    }
    console.log('disableFieldByIndEstero END');

}


@api
handleChangeComune(event){
    console.log('event value : ******++'+ JSON.stringify(event.target.value));
    console.log('event detail : ******++'+ JSON.stringify(event.target.detail));
    console.log('entra qui+++++++++++++++++++++++++++');
    
    if(this.IndEstero==true){

    }else{

    
    if((event.target.value.length==3 && event.target.name =='Comune')){
        getAddressComune({city:event.target.value}).then(data =>
            {
                
                console.log("******HOLAHOLA:" + JSON.stringify(data));
                if(data['statusCode'] == 200 && data['prestazione'].length > 0){
                    this.statusCodeComune = data['statusCode'];
                    console.log("Sucessoooooooooooo:" + JSON.stringify(data));
                    this.herokuAddressServiceData = data['prestazione'];
                    this.headertoshow = 'Comune';
                    if(this.IndEstero==true)
                    {
                        this.booleanForm=false;
                    }
                    else
                    {
                        this.booleanForm=true;

                        this.template.querySelector('c-hdt-selection-address-response').openedForm();
                        this.template.querySelector('c-hdt-selection-address-response').valorizeTable(data['prestazione'],'Citta');
                        this.template.querySelector('c-hdt-selection-address-response').handleFilterDataTable(event);

                    }
                    
                }
                else{
                    let event2;
                    if(data['statusCode'] != 200){
                        event2 = new ShowToastEvent({
                            title: 'Errore',
                            variant: 'error',
                            message: "errore di connessione, riprovare o contattare l'amministratore"
                        });
                        
                    }
                    else{
                        event2 = new ShowToastEvent({
                            title: 'Errore',
                            variant: 'error',
                            message: 'Non sono presenti Comuni corrispondenti ai caratteri inseriti. Digitare nuovamente per effettuare una nuova ricerca.'
                        });
                    }
                    this.dispatchEvent(event2);
                }
                
    
    
        });
    }

        if(this.statusCodeComune==200){
            console.log('entra in if statusCodeComune == 200');
            this.template.querySelector('c-hdt-selection-address-response').handleFilterDataTable(event);

        }
    }
    

        this.textFieldValue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        console.log(event.target.name + ' now is set to ' + event.target.value);
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
        switch(event.target.name){
            case 'Civico':
                this.civico = event.target.value;
                break;
            case 'Comune':
                this.comune =  event.target.value;
                break;
            case 'Stato':
                this.stato = event.target.value;
                break;
            case 'Provincia':
                this.provincia = event.target.value;
                break;
            case 'Via':
                this.via= event.target.value;
                
                break;
            case 'CAP':
                this.cap= event.target.value;
                break;
            case 'Estens.Civico':
                this.estensCivico = event.target.value;
                console.log('estensione civico'+ JSON.stringify(event.target.value));
                break;
            case 'Codice Comune SAP':
                this.codComuneSAP = event.target.value;
                console.log('codComSAP'+ JSON.stringify(this.estensCivico));
                break;
            case 'Codice Via Stradario SAP':
                this.codStradarioSAP = event.target.value;
                console.log('codStradario'+ JSON.stringify(this.estensCivico));
                break;
        }
        this.flagVerificatoFalse();
        this.wrapAddressObject = this.toObjectAddressInit(this.theRecord);
       
        console.log('wrapAddressObject -handleTextChange ********************'+ JSON.stringify(this.wrapAddressObject));

}


@api
handleChangeIndirizz(event){
    console.log('event value : ******++'+ JSON.stringify(event.target.value));
    console.log('event detail : ******++'+ JSON.stringify(event.target.detail));
    console.log('entra qui+++++++++++++++++++++++++++');
    if(this.IndEstero==true){

    }else{

    
    if((event.target.value.length==5 && event.target.name =='Via')){
        getAddressInd({street:event.target.value,cityCode:this.codComuneSAP}).then(data =>
            {
                console.log("******HOLAHOLA:" + JSON.stringify(data));
                if(data['statusCode'] == 200 && data['prestazione'].length > 0){
                    console.log("Sucessoooooooooooo:" + JSON.stringify(data));
                    this.herokuAddressServiceData = data['prestazione'];
                    this.headertoshow = 'Via';
                    this.booleanForm=false;
                    this.booleanForm=true;

                    this.template.querySelector('c-hdt-selection-address-response').openedForm2();
                    this.template.querySelector('c-hdt-selection-address-response').valorizeTable(data['prestazione'],'Via');
                }
                else{
                    let event2;
                    if(data['statusCode'] != 200){
                        event2 = new ShowToastEvent({
                            title: 'Errore',
                            variant: 'error',
                            message: "errore di connessione, riprovare o contattare l'amministratore"
                        });
                        
                    }
                    else{
                        event2 = new ShowToastEvent({
                            title: 'Errore',
                            variant: 'error',
                            message: 'Non sono presenti Indirizzi corrispondenti ai caratteri inseriti . Digitare nuovamente per effettuare una nuova ricerca.',
                        });
                    }
                    this.dispatchEvent(event2);
                }
                
    
    
        });
    }
    }
    

        this.textFieldValue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        console.log(event.target.name + ' now is set to ' + event.target.value);
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
        switch(event.target.name){
            case 'Civico':
                this.civico = event.target.value;
                break;
            case 'Comune':
                this.comune =  event.target.value;
                break;
            case 'Stato':
                this.stato = event.target.value;
                break;
            case 'Provincia':
                this.provincia = event.target.value;
                break;
            case 'Via':
                this.via= event.target.value;
                break;
            case 'CAP':
                this.cap= event.target.value;
                break;
            case 'Estens.Civico':
                this.estensCivico = event.target.value;
                console.log('estensione civico'+ JSON.stringify(event.target.value));
                break;
            case 'Codice Comune SAP':
                this.codComuneSAP = event.target.value;
                console.log('codComSAP'+ JSON.stringify(this.estensCivico));
                break;
            case 'Codice Via Stradario SAP':
                this.codStradarioSAP = event.target.value;
                console.log('codStradario'+ JSON.stringify(this.estensCivico));
                break;
        }
        this.flagVerificatoFalse();
        this.wrapAddressObject = this.toObjectAddressInit(this.theRecord);
        console.log('wrapAddressObject -handleTextChange ********************'+ JSON.stringify(this.wrapAddressObject));

}






@api
handleTextChange(event){
    console.log('event value : ******++'+ JSON.stringify(event.target.value));
    console.log('event detail : ******++'+ JSON.stringify(event.target.detail));
    console.log('entra qui+++++++++++++++++++++++++++');
    
    if((event.target.value.length>2 && event.target.name =='Comune')||(event.target.value.length>4 && event.target.name =='Via')){
        this.booleanForm=true;
        this.template.querySelector('c-hdt-selection-address-response').openedForm();
        this.template.querySelector('c-hdt-selection-address-response').connectedCallback();
    }

        this.textFieldValue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        console.log(event.target.name + ' now is set to ' + event.target.value);
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
        switch(event.target.name){
            case 'Civico':
                this.civico = event.target.value;
                break;
            case 'Comune':
                this.comune =  event.target.value;
                break;
            case 'Stato':
                this.stato = event.target.value;
                break;
            case 'Provincia':
                this.provincia = event.target.value;
                break;
            case 'Via':
                this.via= event.target.value;
                break;
            case 'CAP':
                this.cap= event.target.value;
                break;
            case 'Estens.Civico':
                this.estensCivico = event.target.value;
                break;
            case 'Codice Comune SAP':
                this.codComuneSAP = event.target.value;
                break;
            case 'Codice Via Stradario SAP':
                this.codStradarioSAP = event.target.value;
                break;
        }
        this.flagVerificatoFalse();
        
        this.wrapAddressObject = this.toObjectAddressInit(this.theRecord);
        console.log('wrapAddressObject -handleTextChange ********************'+ JSON.stringify(this.wrapAddressObject));
        if(this.codComuneSAP != null && this.codStradarioSAP != null && this.civico != null){
            this.disableVerifIndiButton = false;
        }
        else{
            this.disableVerifIndiButton = true;
        }
    
}

@api
    handleAddressFields(){
        console.log('saveAddressField - wrapAddressObject START '+ JSON.stringify(this.theRecord));
        return this.theRecord;

    }

@api
disabledverifyFieldsAddressDisabled(){
    this.verifyFieldsAddressDisabled= false;
}

@api
    toObjectAddressInit(data){

        let fieldsDataObject = [];
        
        Object.keys(data).forEach(keys=> {
        
           

                fieldsDataObject.push(
                    {
                        fieldname: keys,
                        required : false,
                        value: data[keys],
                        disabled: false
                    }
                ) 

        });

        return fieldsDataObject;
    }

@api
    connectedCallback()
    {
        this.disableFlagVerificato=true;
        console.log('hdtTargetObjectAddressFields - fieldAddressObject : '+ JSON.stringify(this.fieldsaddressobject));
        console.log('connectedCallback  START + theRecord : '+JSON.stringify(this.theRecord));
        console.log('connectedCallback   objectApiName : '+JSON.stringify(this.objectapiname));
        if(this.objectapiname=='Account'){
            this.visibleCopiaResidenza=false;
            this.visibleSelezioneIndirizzi=false;
        }else{
            this.visibleCopiaResidenza=true;
            this.visibleSelezioneIndirizzi=true;
        }

        if(this.IndEstero==true){
            this.stato='ESTERO';
        }

        this.theRecord['Stato'] = this.stato;

        console.log('connectedCallback indirizzo estero : ' + JSON.stringify(this.IndEstero));
        this.disableFieldByIndEstero();
        
    }


@api
    getInstanceWrapObject(servicePointRetrievedData){
        console.log('getInstanceWrapObject - START');
        console.log('getInstanceWrapObject - servicePointRetrievedData' +JSON.stringify(servicePointRetrievedData));
        getInstanceWrapAddressObject({s:servicePointRetrievedData}).then(data => {
            this.handleAddressValues(data);
            console.log('getInstanceWrapObject - getInstanceWrapAddressObject Start '+ JSON.stringify(data));
            //this.wrapAddressObject = this.toObjectAddressInit(data);
            if(this.codComuneSAP != null && this.codStradarioSAP != null && this.civico != null){
                this.disableVerifIndiButton = false;
            }
            else{
                this.disableVerifIndiButton = true;
            }
            console.log('getInstanceWrapObject - wrapAddressObject' + JSON.stringify(this.wrapAddressObject));
            //this.toObjectAddress();
            
        });
        
        console.log('getInstanceWrapObject - END');
    }


		
													 
	
    @api
    getInstanceWrapObjectBilling(billingProfileData){
        this.handleAddressValues(billingProfileData);
        this.theRecord = billingProfileData;
    }												 
											
	 

    /**
     * Get availability of verify address button
     */
    
    /*get verifyFieldsAddressDisabled(){
        console.log('verifyFieldsAddressDisabled - START ' + JSON.stringify(this.wrapAddressObject));
        let result = true;       
        

        if(
            (
                (this.submitedAddressFields.SupplyCountry__c != undefined
                && this.submitedAddressFields.SupplyCity__c != undefined
                && this.submitedAddressFields.SupplyPostalCode__c != undefined)
                &&
                (this.submitedAddressFields.SupplyCountry__c != ''
                && this.submitedAddressFields.SupplyCity__c != ''
                && this.submitedAddressFields.SupplyPostalCode__c != '')
            )
            || !this.verifyDisabledOnUpdate
        ){
            result = false;
        }
        
        return result;
    }*/
@api
    stampWrapObject(){
        console.log('wrapAddressObject in StampWrapAddressObject*******************'+ this.wrapAddressObject);
    }

  @api  
     objectToMap(wrapAddressObject) {
        console.log('hdtTargetObjectAddressFields - objectToMap START');  
        let wrapObjectInput=[];
        console.log('arrivo qui');

        const ObjArray = Object.getOwnPropertyNames(wrapAddressObject);
        console.log('arrivo qui1');
        for(let i = 0; i < ObjArray.length; i++){
            console.log('entra nel for'+ ObjArray[i]);
           //inserting new key value pair inside map
           this.wrapObjectInput.set(ObjArray[i], obj[ObjArray[i]]);
        };
        console.log('hdtTargetObjectAddressFields - objectToMap END');
        return wrapObjectInput;
    }

    @api
     toObjectAddress(){
        console.log('hdtTargetObjectAddressFields - toObjectAddress START');
        this.fieldsAddressObject= this.wrapAddressObject;
        /*let fieldMap = this.objectToMap(this.wrapAddressObject);
        console.log(''+fieldMap.keys);
        fieldMap.forEach(element => {

                this.fieldsAddressObject.push(
                    {
                        fieldname: element,
                        required : false,
                        value: '',
                        disabled:  false
                    }
                ) 
        });*/
        console.log('hdtTargetObjectAddressFields - toObjectAddress END');

 }

 

    /**
     * Get address fields values
     * @param {*} event 
     */
    handleFieldsDataChange(event){
        this.disabledverifyFieldsAddressDisabled()
        console.log('hdtTargetObjectAddressFields - handleFieldsDataChange Start');
        this.submitedAddressFields[event.target.fieldName] = event.target.value;
        
        let evt = new CustomEvent("getaddressfields", {
            detail: this.submitedAddressFields
          });

        this.dispatchEvent(evt);

        if(this.selectedservicepoint != undefined){
            this.verifyDisabledOnUpdate = false;
            this.dispatchEvent(new CustomEvent("verifyaddressonupdate", {
                detail: this.verifyDisabledOnUpdate
              }));
        }

        this.hasAddressBeenVerified = false;
        this.dispatchEvent(new CustomEvent("addressverification", {
            detail: this.hasAddressBeenVerified
          }));

    }

    /**
     * Show errors for address fields
     * @param {*} fieldsWithError 
     */
    @api
    checkInvalidFields(fieldsWithError){
        for(var i=0; i<fieldsWithError.length; i++){
            
            let dataName = "[data-name='"+fieldsWithError[i]+"']";
            let dataField = this.template.querySelector(dataName);
            dataField.reportValidity();
        }
    }

    /**
     * Verify address
     */
    handleAddressVerification(){

        getAddressRev({modality:'S',cityCode:this.codComuneSAP,streetCode:this.codStradarioSAP,houseNumCode:this.civico}).then(data =>
            {
                
                console.log("******:" + JSON.stringify(data));
                if(data['statusCode'] == 200 && data['prestazione'].length > 0){
                    console.log("Successoooooooooooo:" + JSON.stringify(data));
                    this.comune = data['prestazione'][0].city1;
                    this.codComuneSAP = data['prestazione'][0].cityCode;
                    this.codStradarioSAP = data['prestazione'][0].streetCode;
                    this.cap = data['prestazione'][0].postCode1;
                    this.via = data['prestazione'][0].street;
                    this.civico = data['prestazione'][0].houseNum1;
                    this.provincia = data['prestazione'][0].region;
                    
                    console.log('******PREVERIF:' + this.flagVerificato);
                    this.flagVerificato = true;
                    console.log('******POSTVERIF:' + this.flagVerificato);

                    this.theRecord['Via']= data['prestazione'][0].street;
                    this.theRecord['Civico']= data['prestazione'][0].houseNum1;
                    this.theRecord['Comune']= data['prestazione'][0].city1;
                    this.theRecord['Provincia']= data['prestazione'][0].region;
                    this.theRecord['CAP']= data['prestazione'][0].postCode1;
                    this.theRecord['Codice Comune SAP']= data['prestazione'][0].cityCode;
                    this.theRecord['Codice Via Stradario SAP']= data['prestazione'][0].streetCode;
                    this.theRecord['Flag Verificato'] = true;
                }
                else{
                    console.log("ErrorrrrrreeeeeeeeeEeee:" + JSON.stringify(data));
                }
                
    
    
        }); 
        if(this.theRecord['Stato']=='Italy'||this.theRecord['Stato']=='Italia'){
            this.theRecord['Stato']=='ITALIA';
            this.stato='ITALIA';
        }


      //  this.hasAddressBeenVerified = true;
        
       /* this.dispatchEvent(new CustomEvent("addressverification", {
            detail: this.hasAddressBeenVerified
          }));*/
    }

    handleKeyPress(event){
													  

        if(event.code=='Enter'){

        if(event.target.value.length == 2 && event.target.name == 'Comune' && event.keyCode === 13){

            //this.booleanForm= true;
            getAddressComune({city:event.target.value}).then(data =>
                {
                    
																  
                    if(data['statusCode'] == 200 && data['prestazione'].length > 0){
																				  
                        this.herokuAddressServiceData = data['prestazione'];
                        this.dispatchEvent(new CustomEvent('herokuaddress', {detail: this.herokuAddressServiceData}));
                        this.headertoshow = 'Comune';
                        
                        this.booleanForm=true;
                        this.template.querySelector('c-hdt-selection-address-response').openedForm();
                        this.template.querySelector('c-hdt-selection-address-response').valorizeTable(data['prestazione'],'Citta');
                    }
                    else{
                        let event2;
                        if(data['statusCode'] != 200){
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: "errore di connessione, riprovare o contattare l'amministratore"
                            });
                            
                        }
                        else{
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: 'Non sono presenti Comuni corrispondenti ai caratteri inseriti. Digitare nuovamente per effettuare una nuova ricerca.'
                            });
                        }
                        this.dispatchEvent(event2);
                    }
                    
        
        
            });

        }
        if((event.target.value.length >= 2 && event.target.value.length <=4)  && event.target.name == 'Via' && event.keyCode === 13){
										   
            getAddressInd({street:event.target.value,cityCode:this.codComuneSAP}).then(data =>
                {
                    
																		  
                    if(data['statusCode'] == 200 && data['prestazione'].length > 0){
                        console.log("Sucessoooooooooooo:" + JSON.stringify(data));
                        this.herokuAddressServiceData = data['prestazione'];
                        this.headertoshow = 'Via';
                        this.booleanForm=false;
                        this.booleanForm=true;
    
                        this.template.querySelector('c-hdt-selection-address-response').openedForm2();
                        this.template.querySelector('c-hdt-selection-address-response').valorizeTable(data['prestazione'],'Via');
                    }
                    else{
                        let event2;
                        if(data['statusCode'] != 200){
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: "errore di connessione, riprovare o contattare l'amministratore"
                            });
                            
                        }
                        else{
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: 'Non sono presenti Indirizzi corrispondenti ai caratteri inseriti . Digitare nuovamente per effettuare una nuova ricerca.',
                            });
                        }
                        this.dispatchEvent(event2);
                    }
                    
        
        
            });
        }
    } 
}  


}