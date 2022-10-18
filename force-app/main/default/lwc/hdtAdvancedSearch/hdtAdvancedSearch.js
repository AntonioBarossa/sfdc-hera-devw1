import {LightningElement, track,api} from 'lwc';
import getServicePoints from '@salesforce/apex/HDT_LC_AdvancedSearch.getServicePoints';
import getContracts from '@salesforce/apex/HDT_LC_AdvancedSearch.getContracts';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getForniture from '@salesforce/apex/HDT_LC_AdvancedSearch.getForniture';
import getCustomMetadata from '@salesforce/apex/HDT_QR_FiltriProcessi.getCustomMetadata';
import getCustomMetadataList from '@salesforce/apex/HDT_QR_FiltriProcessi.getCustomMetadataList';
import callService from '@salesforce/apex/HDT_WS_ArrichmentDataEntityInvoker.callService';
import extractDataFromArriccDataServiceWithExistingSp from '@salesforce/apex/HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp';
import isInBlacklist from '@salesforce/apex/HDT_LC_AdvancedSearch.isInBlacklist';
import permissionForFlagContract from '@salesforce/apex/HDT_LC_AdvancedSearch.permissionForFlagContract';
import checkCompatibility from '@salesforce/apex/HDT_UTL_MatrixCompatibility.checkCompatibilitySales';
import getCustomMetadataTwo from '@salesforce/apex/HDT_QR_HiddenSearchBarPostSales.getCustomMetadataTwo';


export default class HdtAdvancedSearch extends LightningElement {
    @api openCheckBox=false;
    @api sp;
    @api responseArriccData;
    @track filterInputWord = null;
    openmodel = false;
    submitButtonStatus = true;
    searchInputValue = null;
    registryCityValue;
    registryCityCodeValue;
    urbanSectionValue;
    sheetValue;
    particleSheetValue;
    subalternValue;
    queryType = 'pod';
    datiCatastali = {RegistryCity: '', RegistryCityCode: '', UrbanSection: '', Sheet: '', ParticleSheet: '', Subaltern: ''};
    tableData = [];
    tableColumns = [];
    isLoaded = false;
    columns = [];
    originalData = [];
    pages = [];
    preloading = false;
    @track currentPage = 0;
    totalPage = 0;
    customSetting = null;
    confirmButtonDisabled = true;
    @api servicePointRetrievedData;
    @api additionalfilter;
    @api additionalFilterFinal;
    rowToSend;
    @api maxRowSelected=false;
    @api disabledinput;
    @api accountid;
    @api processtype;
    apiSearchButtonStatus= true;
    apiSearchInputValue=null;
    @api targetobject;
    @api outputContract=[];
    @api showbuttoncontract ;
    @api showbuttonforniture=false;
    @api flagContratto=false;
    @api isSuperUser=false;
    @api serviceRequestId;
    @track isIncompatible= false;
    @track preSelectedRows=[];
    @track iconCompatibility='';
    notFoundMsg={
        'pod':'Codice POD/PDR non trovato su SFDC, Eseguire una nuova ricerca o verifica esistenza su SAP',
        'contract':'Codice Contratto non trovato su SFDC, Eseguire una nuova ricerca o verifica esistenza su SAP',
        'serialnumber':'Nessun record trovato',
        'podH2o':'Codice Punto Presa non trovato su SFDC. Eseguire una nuova ricerca o verifica esistenza su SAP',
        'address':'Nessun record trovato'
    }
    @api isRicercainSAP=false;
    postSales=false;
    isSerialNumber = false;
    openMeterSearchModal = false;
    hiddenSearchBarMod=true;

    connectedCallback() {
        permissionForFlagContract().then(data =>{
            console.log('enter in permissionForFlagContract : ' + JSON.stringify(data));
            this.openCheckBox= data;
        });
        if(this.processtype === undefined || this.processtype === ''){
            console.log('processType non popolato');
            this.showbuttonforniture=true;
        }

        else {            
            console.log('processType'+ JSON.stringify(this.processtype));
            
            this.postSales = true;
            this.additionalfilter = (this.additionalfilter===undefined) ? '' : this.additionalfilter;
                       
            getCustomMetadataList({processType:this.processtype}).then(dataArray =>{    
                console.log('LOG ==> DataArray custom metadata: '+JSON.stringify(dataArray));
                let dataFilters = [];
                dataArray.forEach(data =>{              
            
                    let statusSplit=[];
                    let contractStatusSplit=[];
                    let TipoServizioSplit=[];
                    let RateCategorySplit=[];
                    let singleFilter=[];

                    if(data.FornitureCliente__c == 'SI') {
                        console.log('entra in forniture cliente == SI');

                        if(data.StatoFornitura__c != undefined && data.StatoFornitura__c!='') {
                            statusSplit = data.StatoFornitura__c.split(",");
                            singleFilter.push(" MeterStatus__c IN('" + statusSplit.join("','") + "') ");
                        }

                        if(data.StatoContratto__c != undefined && data.StatoContratto__c != '') {
                            contractStatusSplit = data.StatoContratto__c.split(",");
                            if(contractStatusSplit.includes("Bozza")){
                                contractStatusSplit.push("");
                            }
                            singleFilter.push(" SapContractStatus__c IN('" + contractStatusSplit.join("','") + "') "); 
                        }

                        if(data.TipoServizio__c!= undefined && data.TipoServizio__c!='') {
                            TipoServizioSplit = data.TipoServizio__c.split(",");
                            singleFilter.push(" CommoditySector__c IN('" + TipoServizioSplit.join("','") + "') ");
                        }
                                
                        if(data.Disalimentabile__c!= undefined && data.Disalimentabile__c!='') {
                            singleFilter.push(" Disconnectable__c = '"+data.Disalimentabile__c+"' ");
                        }

                        if(data.RateCategory__c!=undefined && data.RateCategory__c!='' && this.processtype !='Chiusura Contatore' && this.processtype != 'Esenzione Modifica Fognatura Depurazione') {
                            RateCategorySplit = data.RateCategory__c.split(",");
                            if(this.processtype !='Chiusura Contatore' && this.processtype != 'Esenzione Modifica Fognatura Depurazione'){
                                singleFilter.push(" RateCategory__c IN('" + RateCategorySplit.join("','") + "') ");
                            }else{
                                singleFilter.push(" RateCategory__c NOT IN('" + RateCategorySplit.join("','") + "') ");                            
                            }
                        }
                    }

                    if (singleFilter.length > 0) {
                        dataFilters.push( " (" + singleFilter.join(" AND ") + ") ");
                    }                   
                }); 
                if (dataFilters.length > 0) {
                    this.additionalFilterFinal = " AND (" + dataFilters.join(" OR ") + ") ";
                }
                console.log('LOG ==> this.additionalFilterFinal: '+ this.additionalFilterFinal);
                this.submitFornitura();
            });
        }
        this.maxRowSelected = (this.maxRowSelected ===false) ? 1 : this.originalData.length;        

        if (this.maxRowSelected ===false){
            this.maxRowSelected= 1
        }else {
            this.maxRowSelected = this.originalData.length
        }

        getCustomMetadataTwo({processType:this.processtype,targetObject:this.targetObject}).then(data =>{
            console.log('targetObject XXX'+ JSON.stringify(this.targetobject));
            console.log('processType XXX'+ JSON.stringify(this.processtype));
            this.hiddenSearchBarMod=false;
            if(data==='List is populated'){
                this.hiddenSearchBarMod=true;
            }
        });
        
    }

    @api
    handleAdditionalFilter(processtype){
        let processT = processtype;
        console.log('enter in handleAdditionalFilter');
        console.log('processType******************'+JSON.stringify(processT));

       /* if(processT ==='Voltura Tecnica'){
            console.log('entra qui Modifica***************');
          
            this.submitFornitura();
        }*/
        if(processT==='Annullamento contratti')
        {
            console.log('entra qui Cessazioni***************');
            this.submitContract();
            
        }
    }


    /**
     * Filter Data-Table
     */
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

    /**
     * validate search input length
     */
    handleSearchInputKeyChange(event) {
        this.searchInputValue = event.target.value;
        if (this.searchInputValue.length > 3) {
            this.submitButtonStatus = false;
        } else {
            this.submitButtonStatus = true;
        }
    }

    showToast(message) {
        const event = new ShowToastEvent({
            title: 'Attenzione',
            message: message,
            variant: 'error',
            mode:'sticky',
        });
        this.dispatchEvent(event);
    }

    @track openmodelDatiCatastali = false;

    openModalDatiCatastali() {
        this.openmodelDatiCatastali = true
    }

    closeModalDatiCatastali(){        
        this.openmodelDatiCatastali = false;
    }

    handleRegistryCity(event){
        this.registryCityValue = event.target.value;
    }
    handleRegistryCityCode(event){
        this.registryCityCodeValue = event.target.value;
    }
    handleUrbanSection(event){
        this.urbanSectionValue = event.target.value;
    }
    handleSheet(event){
        this.sheetValue = event.target.value;
    }
    handleParticleSheet(event){
        this.particleSheetValue = event.target.value;
    }
    handleSubaltern(event){
        this.subalternValue = event.target.value;
    }     

    addValuesToDatiCatastaliList() {
        console.log('****Sono nella funcion****');
        let errorMessage = [];
        let concatErrorFields = '';
        console.log('****Sono dopo le variabili****');
        this.searchInputValue = '';
        if(this.registryCityValue){
            this.datiCatastali.RegistryCity = this.registryCityValue;
            this.searchInputValue += this.registryCityValue + ' ';
        }
        if(this.registryCityCodeValue){
            this.datiCatastali.RegistryCityCode = this.registryCityCodeValue;
            this.searchInputValue += this.registryCityCodeValue + ' ';
        }
        if(this.urbanSectionValue){
            this.datiCatastali.UrbanSection = this.urbanSectionValue;
            this.searchInputValue += this.urbanSectionValue + ' ';
        }
        if(this.sheetValue){
            this.datiCatastali.Sheet = this.sheetValue;
            this.searchInputValue += this.sheetValue + ' ';
        }
        if(this.particleSheetValue){
            this.datiCatastali.ParticleSheet = this.particleSheetValue;
            this.searchInputValue += this.particleSheetValue + ' ';
        }
        if(this.subalternValue){
            this.datiCatastali.Subaltern = this.subalternValue;
            this.searchInputValue += this.subalternValue + ' ';
        }
        if(this.registryCityValue == null && this.registryCityCodeValue == null || this.registryCityValue == '' && this.registryCityCodeValue == '' || this.registryCityValue == null && this.registryCityCodeValue == '' || this.registryCityValue == '' && this.registryCityCodeValue == null){
            concatErrorFields = concatErrorFields.concat('Comune catastale o in alternativa Codice comune catastale, ');
        }
        if(this.sheetValue == null || this.sheetValue == ''){
            concatErrorFields = concatErrorFields.concat('Foglio, ');
        }
        if(this.particleSheetValue == null || this.particleSheetValue == ''){
            concatErrorFields = concatErrorFields.concat('Particella');
        }
        if (concatErrorFields.charAt(concatErrorFields.length - 2) == ',') {
            concatErrorFields = concatErrorFields.slice(0, -2);
          }
        
        if (concatErrorFields !== '') {
            errorMessage.push('Per poter confermare popolare i seguenti campi: ' + concatErrorFields);
        }        
        if(errorMessage.length === 0){
            this.closeModalDatiCatastali();
        }else{
            this.showToast(errorMessage[0]);
        }       
        this.submitButtonStatus = false;
    } 

    closeModal() {
        this.confirmButtonDisabled=true;
        this.openmodel = false;
        console.log('*********:1' + this.serviceRequestId);
        console.log('*********:2' + this.isIncompatible);
        if(this.serviceRequestId != null && this.isIncompatible){
            this.dispatchEvent(new CustomEvent('servicepointselectioncancel', {
                detail: this.rowToSend
            }));
        }
    }

    /**
     * get input value and also validate input value
     */
    searchAction(event) {
        console.log(this.queryType);
        this.submitButtonStatus = true;
        this.apiSearchButtonStatus = true;
        console.log('event value: '+ event.target.value);
        if (event.target.value.length > 3) {
            this.submitButtonStatus = false;
            this.searchInputValue = event.target.value;
        }
        if(this.queryType==='datiCatastali'){
            this.openModalDatiCatastali();
        }
        
    }

    /**
     * Create header for Data-Table header with original data
     */
    formatTableHeaderColumns(rowData) {
        let columns = [];
        this.tableColumns = [];
        console.log('rowData*******************' + JSON.stringify(rowData));
        rowData.forEach(row => {
            let keys = Object.keys(row);
            columns = columns.concat(keys);
        });
        let columnsUniq = [...new Set(columns)];
        columnsUniq.forEach(field => 
            {
                if(field != 'iconCompatibility' && field != 'compatibilityMessage' && field != 'Id' && field != 'serviceRequestId' && field != 'isCompatible' && field !== 'ServicePointId'){
                    this.tableColumns.push({label: field, fieldName: field});
                }                 
            });
            if(this.processtype != ''){                 
                if(this.isIncompatible){
                    this.tableColumns.push(
                        { label: 'Compatibility', fieldName: 'compatibility',
                            type: 'button',
                            typeAttributes: {
                                label: 'See more',
                                title: {fieldName:'compatibilityMessage'},
                            },
                            cellAttributes:{ 
                                iconName:{ fieldName: 'iconCompatibility'},
                                iconPosition: 'left', 
                                iconAlternativeText: 'Compatibility Icon' ,
                            }
                        });
                }else{
                    this.tableColumns.push(
                        { label: 'Compatibility', fieldName: 'compatibility',
                            cellAttributes:{ 
                                iconName:{ fieldName: 'iconCompatibility'},
                                iconPosition: 'left', 
                                iconAlternativeText: 'Compatibility Icon' ,
                            }
                        });
                }
            }
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

    reLoadTable() {
        this.tableData = this.pages[this.currentPage];

        console.log('tableData********'+ JSON.stringify(this.tableData));

    }

    nextPage() {
        if (this.currentPage < this.totalPage - 1) this.currentPage++;
        this.reLoadTable();
    }

    previousPage() {
        if (this.currentPage > 0) this.currentPage--;
        this.reLoadTable();
    }

    alert(title,msg,variant){
        const event = ShowToastEvent({
            title: title,
            message:  msg,
            variant: variant
        });
        dispatchEvent(event);
    }

    get getCurrentPage() {
        if (this.totalPage===0) return 0;
        return this.currentPage + 1;
    }

    
    onselected(event){
        console.log('Event ' + JSON.stringify(event));
        this.queryType = event.detail;
        console.log('## QueryType >>> ' + this.queryType);
        if(this.queryType==='datiCatastali'){
            this.openModalDatiCatastali();
        }
        
        if (this.queryType==='serialnumber'){
            this.isSerialNumber = true;
        } else {
            this.isSerialNumber = false;
        }
        
        this.apiSearchButtonStatus= true;
    }


@api
    submitContract(){
        this.preloading = true;
        console.log('executing query search', this.accountid);
        console.log('additionalFilter************:'+JSON.stringify(this.additionalfilter));

            getContracts({accountid:this.accountid,additionalFilter:this.additionalfilter}).then(data =>{
                this.preloading = false;
                if (data.length > 0) {
                    this.originalData = JSON.parse(JSON.stringify(data));
                    this.createTable(data);
                    this.formatTableHeaderColumns(data);
                    this.submitButtonStatus = true;
                    this.openmodel = true;
                    this.isLoaded = true;
                } else {
                    this.alert('Dati tabella','Nessun record trovato','warn')
                    this.tableData = data;
                }
            });       
    }

@api
    submitFornitura(){
        this.preSelectedRows=[];
        this.isIncompatible= false;
        this.preloading = true;
        
        getForniture({accountid:this.accountid, additionalFilter:this.additionalFilterFinal}).then(data =>{
            this.preloading = false;
            if (data.length > 0) {
                this.originalData = JSON.parse(JSON.stringify(data));
                console.log('this.originalData ' + JSON.stringify(this.originalData));
                for(var i=0; i<this.originalData.length; i++){
                    this.originalData[i].Id=i.toString();
                }
                this.createTable(this.originalData);
                this.formatTableHeaderColumns(this.originalData);
                this.submitButtonStatus = true;
                this.openmodel = true;
                this.isLoaded = true;
                this.serviceRequestId = null;
            }
            else {
                this.alert('Dati tabella','Nessun record trovato','warn')
                this.tableData = data;
            }
        });
    }

    searchInSAP(){
        
        if(this.isSerialNumber){
            console.log('Set openMeterSearchModal -> True');
            this.openMeterSearchModal = true;
        }else{
            this.callApi(this.searchInputValue, 'searchSap').then(() => {
                this.preloading = true;
                this.closeModal();
                if(this.serviceRequestId == null || (this.serviceRequestId != null && !this.isIncompatible)){
                    this.dispatchEvent(new CustomEvent('servicepointselection', {
                        detail: this.rowToSend
                    }));
                    this.preloading = false;
                }
                this.confirmButtonDisabled = true;
            });
        }
    }

    callApi(event, isFrom){
        return new Promise((resolve) => {
            this.preloading = true;
            this.isRicercainSAP= true;
            this.searchInputValue = event;
            console.log('#Length Event >>> ' + this.searchInputValue.length);
            let contractCode = this.searchInputValue.length >= 14 ? '' : this.searchInputValue;
            let servicePointCode = this.searchInputValue.length >= 14 ? this.searchInputValue : '';
            let implantCode = this.searchInputValue.length === 10 && this.searchInputValue.startsWith("4")? this.searchInputValue:'';
            this.dispatchEvent(new CustomEvent('ricercainsap', {
                detail: this.isRicercainSAP
            }));
            callService({contratto:contractCode, pod:servicePointCode,impianto:implantCode}).then(data =>{            
                if(data.statusCode=='200' || this.postSales === true){
                    if(data.statusCode != '200')
                    {
                        resolve();
                        return;
                    }
                    this.responseArriccData = data;
                    extractDataFromArriccDataServiceWithExistingSp({sp:'',response:data}).then(datas =>{
                        let sp = datas;
                        this.sp=sp;
                        if(sp!= undefined|| sp != null){
                            this.rowToSend = datas;
                            this.preloading = false;
                            resolve();
                        }
                        else{
                            this.alert('Errore','Il dato ricercato non è stato trovato in SAP, Modificare i parametri di ricerca o procedere alla creazione manuale.','error');
                            this.preloading = false;
                        }        
                    });
                }
                else{
                    if(this.postSales || isFrom == 'searchSap'){
                        this.alert('Errore','Il dato ricercato non è stato trovato in SAP, Modificare i parametri di ricerca o procedere alla creazione manuale.','error');
                        this.preloading = false;
                    }
                    else{
                        resolve();
                    }
                }
            });
        });
    }

    /**
     * Call apex class and get data
     */
    submitSearch(event) {
        this.preSelectedRows=[];
        this.isIncompatible= false;
        event.preventDefault();
        let isBlacklist=false;
        this.preloading = true;
        let qty = this.queryType;
        isInBlacklist({pod:this.searchInputValue}).then(data =>{
            isBlacklist=data;
        
        if(isBlacklist == false){
        getServicePoints({parameter: this.searchInputValue,queryType:this.queryType,additionalFilter:this.additionalfilter,isSuperUser:this.isSuperUser, datiCatastali: JSON.stringify(this.datiCatastali)}).then(data => {
            this.preloading = false;
            if (data.length > 0) {
                
                this.originalData = JSON.parse(JSON.stringify(data));
                for(var i=0; i<this.originalData.length; i++){
                     this.originalData[i].Id=i.toString();
                }
                this.createTable(this.originalData);
                this.formatTableHeaderColumns(this.originalData);
                this.submitButtonStatus = true;
                this.openmodel = true;
                this.isLoaded = true;
                this.apiSearchButtonStatus=true;
                this.searchInputValue= null;
            } else {
                this.alert('Dati tabella',this.notFoundMsg[qty],'warn')
                this.tableData = data;
                this.apiSearchButtonStatus=false;
            }
        }).catch(error => {
            this.preloading = false;
            let errorMsg = error;
            if ('body' in error && 'message' in error.body) {
                errorMsg = error.body.message
            }
            this.alert('',errorMsg,'error')
        });
    }else{
        this.preloading = false;
        console.log('entra in else');
        this.alert('Errore','Non è possibile procedere in quanto il POD/PD ricercato è presente in Black List','error');
    }
        });
 

    }
     /**
     * Get selected record from table
     */
    getSelectedServicePoint(event){
        this.preloading = true;
        let selectedRows = event.detail.selectedRows;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        console.log('rowToSend*************************' + JSON.stringify(this.rowToSend));
        console.log('getSelectedServicePoint END');

        if(this.processtype != ''){
            let srvRequest= {
                'servicePointCode': this.rowToSend['Codice Punto'],
                'servicePoint': this.rowToSend['ServicePointId'],
                'commoditySector': this.rowToSend['Servizio'],
                'processType': this.processtype,
                'type': 'Case'
            };
            let isPostSales = true;
            checkCompatibility({servReq: srvRequest, isPostSales: isPostSales}).then(data =>{
                if(data.compatibility == ''){
                    this.iconCompatibility='action:approval';
                }else{
                    this.iconCompatibility='action:close';
                }
                this.serviceRequestId= data.ServiceRequest.Id;
                let found= false;
                for(var i=0; i< this.originalData.length;i++){
                    let row= this.originalData[i];
                    if(row['Codice Punto']== this.rowToSend['Codice Punto']){
                        found =true;
                    }
                    if(found){
                        this.isIncompatible= false;
                        row.iconCompatibility= this.iconCompatibility;
                        row.serviceRequestId= this.serviceRequestId;
                        row.isCompatible= true;
                        if(data.compatibility != ''){
                            this.isIncompatible=true;
                            row.isCompatible= false;
                            row.compatibilityMessage= data.compatibility;
                            this.confirmButtonDisabled = true;
                        }else{
                            this.confirmButtonDisabled = false;
                        }
                    }
                }
                console.log(this.originalData);
                this.createTable(this.originalData); 
                this.formatTableHeaderColumns(this.originalData);
                var my_ids = [];
                my_ids[0] = this.rowToSend.Id;
                this.preSelectedRows = my_ids;

            }).catch(error => {
                console.log(error.body.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
                this.confirmButtonDisabled = true;
            });
            this.preloading = false;

        }
        else{
            this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
            this.preloading = false;
        }
    }

         /**
     * Get selected record from table
     */
    getSelectedServicePoint2(rows){
        this.preloading = true;
        let selectedRows = rows;
        this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        this.preloading = false;
    }

    /**
     * Handle action when confirm button is pressed
     */
    handleConfirm(){

        //ANDARE A CONTROLLARE CHE FACCIO LA CHIAMATA LA CALLAPI SOLO IN POST VENDITA
        this.preloading = true;
        let servPoint = this.rowToSend;
        let pointCode = servPoint['Codice Punto'];
        let implantCode = servPoint['Impianto SAP'];
        let codeCallApi = servPoint['Codice Punto'] !== null && servPoint['Codice Punto'] !== undefined && servPoint['Codice Punto'] !== ''?pointCode:!implantCode ? '' : implantCode;
        this.callApi(codeCallApi, 'confirm').then(() => {
            this.preloading = true;
            this.closeModal();
            if(this.serviceRequestId == null || (this.serviceRequestId != null && !this.isIncompatible)){
                this.dispatchEvent(new CustomEvent('servicepointselection', {
                    detail: servPoint
                }));
                if(this.postSales){
                    this.dispatchEvent(new CustomEvent('confirmservicepoint', {
                        detail: servPoint
                    }));
                }
                else{
                    this.preloading = false;
                }
            }
            this.confirmButtonDisabled = true;
        });
    }

@api
    getTargetObject(targetObject){
        this.targetObject = targetObject;
    }

@api
    handleCheckBoxChange(event){

        this.flagContratto = event.target.checked;
        if(this.flagContratto==true){
            this.isSuperUser=true;
        }
        else{
            this.isSuperUser=false;
        }
    }

    handleCloseMeterSearch(){
        console.log('Set openMeterSearchModal -> False');
        this.openMeterSearchModal = false;
    }

    handleServicePoinSelectionMeter(event){
        this.dispatchEvent(new CustomEvent('servicepointselection', {
            detail: event.detail
        }));
        this.handleCloseMeterSearch();
        this.preloading = false;
    }
}