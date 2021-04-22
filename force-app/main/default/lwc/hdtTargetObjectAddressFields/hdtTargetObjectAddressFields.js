import { LightningElement, api, track } from 'lwc';
import getInstanceWrapAddressObject from '@salesforce/apex/HDT_UTL_ServicePoint.getInstanceWrapAddressObject';
import getIndirizzo from '@salesforce/apex/HDT_LC_AdvancedSearch.getIndirizzo';
import getIndirizzoFornitura from '@salesforce/apex/HDT_LC_AdvancedSearch.getIndirizzoFornitura';
import getAddressFromAccount from '@salesforce/apex/HDT_LC_AdvancedSearch.getAddressFromAccount';
export default class hdtTargetObjectAddressFields extends LightningElement {
    @api objectapiname;
    @api fieldsAddressObject=[];
    @api wrapObjectInput= [];
    @api wrapAddressObject;
    @api fieldsDataReq;
    @api selectedservicepoint;
    @api servicePointRetrievedData ;
    hasAddressBeenVerified = false;
    @track submitedAddressFields = {};
    verifyDisabledOnUpdate = true;
    verifyFieldsAddressDisabled= true;
    @api recordtype;
    @api checkBoxFieldValue;
    @api textFieldValue;
    @api theRecord = {};
    @api stato;
    @api provincia;
    @api comune;
    @api cap;
    @api via;
    @api civico;
    @api estensCivico;
    @api codComuneSAP;
    @api codStradarioSAP;
    @api IndEstero ;
    @api flagVerifiacto ;
    @track openmodel = false;
    tableData = [];
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
			this.estensCivico='';
            this.codComuneSAP='';
            this.codStradarioSAP='';
            //this.flagVerifiacto=false;

            this.theRecord['Via']= data['Via'];
            this.theRecord['Civico']= data['Civico'];
            this.theRecord['Comune']= data['Comune'];
            this.theRecord['Provincia']= data['Provincia'];
            this.theRecord['CAP']= data['CAP'];
            this.theRecord['Stato']= data['Stato'];
            this.theRecord['Estens.Civico']= '';
            this.theRecord['Codice Comune SAP']= '';
            this.theRecord['Codice Via Stradario SAP']= '';
            //this.theRecord['Flag Verificato']= false;

        }
    });
	
	this.preloading = false;
    console.log(' getAddressFromAccount END****');
}

    handleConfirm(){
        console.log('entra in handleconfirm');
        this.preloading = true;
        this.closeModal();
		let data = [];
        console.log(' rowToSend**************'+JSON.stringify(this.rowToSend['Indirizzo']));
        if(this.rowToSend['Indirizzo']!=undefined){
            data = this.rowToSend['Indirizzo'].split(",");
            console.log('data after rowToSend**************'+JSON.stringify(data));
        }
        else if(this.rowToSend['Indirizzo Fornitura']!=undefined)
        {
            console.log(' rowToSend**************'+JSON.stringify(this.rowToSend['Indirizzo Fornitura']));
            data = this.rowToSend['Indirizzo Fornitura'].split(",");
            console.log('data after rowToSend**************'+JSON.stringify(data));

        }

        if(data!= undefined){

            if(data.length>7){
                this.via= data[0];
                this.civico= data[1];
                this.estensCivico= data[2];
                this.comune=data[4]; 
                this.provincia=data[5];
                this.cap=data[6];
                this.stato=data[7];
            }else{
                this.via= data[0];
                this.civico= data[1];
                this.estensCivico= data[2];
                this.comune=data[3]; 
                this.provincia=data[4];
                this.cap=data[5];
                this.stato=data[6];
            }

            this.theRecord['Via']= this.via;
            this.theRecord['Civico']= this.civico;
            this.theRecord['Estens.Civico']= this.estensCivico;
            this.theRecord['Comune']= this.comune;
            this.theRecord['Provincia']= this.provincia;
            this.theRecord['CAP']= this.cap;
            this.theRecord['Stato']= this.stato;
            }
        
        this.preloading = false;
        console.log('esce da handleconfirm');

    }

    getSelectedServicePoint(event){
        console.log('getSelectedServicePoint START');
        /*table = $("#main_index1").DataTable();
        table.rows( '.selected' ).nodes().to$().removeClass( 'selected' );*/
        
        this.disableCheckBoxFornitura=true;
        this.preloading = true;
        let selectedRows = event.detail.selectedRows;
        this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        console.log('rowToSend ******' + JSON.stringify(this.rowToSend));
        this.preloading = false;
        console.log('getSelectedServicePoint END');
    }
    
    getSelectedAddress(event){
        console.log('getSelectedAddress START');
       /* table = $("#main_index1").DataTable();
        table.rows( '.selected' ).nodes().to$().removeClass( 'selected' );*/

        this.disableCheckBoxFatturazione=true;
        this.preloading = true;
        let selectedRows = event.detail.selectedRows;
        this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        console.log('rowToSend ******' + JSON.stringify(this.rowToSend));
        this.preloading = false;
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
            getIndirizzo({accountId:this.accountid}).then(data =>{
                this.preloading = false;
                if (data.length > 0) {
                    this.originalData = JSON.parse(JSON.stringify(data));
                    this.createTable(data);
                    this.formatTableHeaderColumns(data);
                    this.openmodel = true;
                    this.isLoaded = true;
                } else {
                   
                    this.tableData=[];
                    this.tableData = data;
                }
            });
            
            getIndirizzoFornitura({accountId:this.accountid}).then(data =>{
                this.preloading = false;
                if (data.length > 0) {
                    this.originalDataFornitura = JSON.parse(JSON.stringify(data));
                    this.createTableFornitura(data);
                    this.formatTableHeaderColumnsFornitura(data);
                    this.openmodel = true;
                    this.isLoaded = true;
                } else {
                    this.alert('Dati tabella','Nessun record trovato','warn')
                    this.tableDataFornitura=[];
                    this.tableDataFornitura = data;
                }
            });
            console.log('tableData******'+ JSON.stringify(this.tableData));
            console.log('tableDataFornitura******'+ JSON.stringify(this.tableDataFornitura));

       
        
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

        console.log('tableData********'+ JSON.stringify(this.tableData));

    }

    reLoadTableFornitura() {
        this.tableDataFornitura=[];
        this.tableDataFornitura = this.pagesFornitura[this.currentPageFornitura];

        console.log('tableDataFornitura********'+ JSON.stringify(this.tableDataFornitura));

    }

    nextPage() {
        if (this.currentPage < this.totalPage - 1) this.currentPage++;
        this.reLoadTable();
    }

    previousPage() {
        if (this.currentPage > 0) this.currentPage--;
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
            break;
            case 'Provincia':
                this.provincia= servicePointRetrievedData[key] ;
            break;
            case 'Comune':
                this.comune= servicePointRetrievedData[key] ;
            break;
            case 'CAP':
                this.cap = servicePointRetrievedData[key] ;
            break;
            case 'Via':
                this.via = servicePointRetrievedData[key] ;
            break;
            case 'Civico':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.civico = servicePointRetrievedData[key] ;
            break;
            case 'EstensCivico':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.estensCivico = servicePointRetrievedData[key] ;
            break;
            case 'CodiceComuneSAP':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.codComuneSAP = servicePointRetrievedData[key] ;
            break;
            case 'CodiceViaStradarioSAP':
                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));
                this.codStradarioSAP = servicePointRetrievedData[key] ;
            break;
            case 'IndirizzoEstero':
                this.IndEstero = servicePointRetrievedData[key] ;
            break;
            case 'FlagVerificato':

                console.log('servicePointRetrievedData[key] *************************************'+JSON.stringify(servicePointRetrievedData[key]));

                this.flagVerifiacto = servicePointRetrievedData[key] ;

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
                this.IndEstero = event.target.checked;
                break;
            case 'Flag Verificato':
                this.flagVerifiacto =  event.target.checked;
                break;
        }


        
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
}
@api
handleTextChange(event){
    console.log('event detail : ******++'+ JSON.stringify(event.target.value));
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
        this.wrapAddressObject = this.toObjectAddressInit(this.theRecord);
        console.log('wrapAddressObject -handleTextChange ********************'+ JSON.stringify(this.wrapAddressObject));

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
        console.log('hdtTargetObjectAddressFields - fieldAddressObject : '+ JSON.stringify(this.fieldsaddressobject));
    }


@api
    getInstanceWrapObject(servicePointRetrievedData){
        console.log('getInstanceWrapObject - START');
        console.log('getInstanceWrapObject - servicePointRetrievedData' +JSON.stringify(servicePointRetrievedData));
        getInstanceWrapAddressObject({s:servicePointRetrievedData}).then(data => {
            this.handleAddressValues(data);
            console.log('getInstanceWrapObject - getInstanceWrapAddressObject Start '+ JSON.stringify(data));
            //this.wrapAddressObject = this.toObjectAddressInit(data);
            
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
        
        this.hasAddressBeenVerified = true;
        
        this.dispatchEvent(new CustomEvent("addressverification", {
            detail: this.hasAddressBeenVerified
          }));
    }


}
