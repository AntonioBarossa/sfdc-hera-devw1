import { LightningElement, api, track , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import cancelCase from '@salesforce/apex/HDT_LC_RecordEditFormSales.cancelCase';
import getActivity from '@salesforce/apex/HDT_LC_RecordEditFormSales.getActivity';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import getParent from '@salesforce/apex/HDT_LC_CopiaContratto.getAccountOrder';
import getChild from '@salesforce/apex/HDT_LC_CopiaContratto.getOrderChild';
import confirmAction2 from '@salesforce/apex/HDT_LC_CopiaContratto.confirmAction';
import confirmAction2Draft from '@salesforce/apex/HDT_LC_CopiaContratto.confirmActionDraft';
import getListRecords from '@salesforce/apex/HDT_LC_ContactSelection.getListRecords';

class fieldData{
    constructor(label, apiname, required, disabled, value) {
        this.label = label;
        this.apiname=apiname;
        this.required=required;
        this.disabled=disabled;
        this.value=value;
    }
}
export default class HdtCopiaContratto extends NavigationMixin(LightningElement){
    @api processtype;
    @api objectName = 'Case';
    @api recordid;
    @api accountId;
    @api saveButton;
    @api tipoAtt;
    @api tiposen;
    @api orderIdPre;
    @api selectedOrderValue;
    @api ismessagevisible = false;
    @api showOrder = false;
    @api cancelButton;
    @api typeDefaltValue;
    @api selectedSend;
    @api draftButton;
    @api isdonedocument = false;
    @api selectedrowchild = [];
    @api acceptedFormats = ['.pdf', '.png'];
    @api statoApp = 'Nessuna Richiesta Inviata';
    @api saveInDraft;
    @api isinboundchannel = false;
    @api showParentList = false;
    @api ordersList = [];
    @api orderChildList = [];
    @api typeActivity = false;
    @api showChildList = false;
    @api showChildList2 = false;
    @api showButtonPreview = false;
    @api showChildListToSelect = false;
    @api cancelCase;
    @track hideCheck = true;
    @api selectedOrder;
    @api isRunFromFlow= false;
    @track showOperationSubType= false;
    @track ordChild;
    @track linkReitek = null;
    @track selectedOperationType;
    @track showSubmitForApprovalButton=false;
    @track disableConfirmButton= false;
    @track preloading= false;
    @api selectedActivity;
    @track tipoCopiaOptions =
    [
        {label:"Copia contratto firmato", value:"Copia contratto firmato"},
        {label:"Copia contratto non firmato", value:"Copia contratto non firmato"},
        {label:"Copia della registrazione", value:"Copia della registrazione"}
    ];
    @track tipoAttivitaOptions =
    [
        {label:"Sportello", value:"Sportello"},
        {label:"Inbound", value:"Inbound"}
    ];
    @track tipoAttivitaOptions2 =
    [
        {label:"Posta Cartacea", value:"Posta Cartacea"},
        {label:"Email", value:"E-Mail"}
    ];

    @track columns = [
        {label: 'Order Number', fieldName: 'OrderNumber', type: 'text'},
        {label: 'Status', fieldName: 'Status', type: 'text'}        
    ];



    get columnsChild(){
        return [
            ...this.columns, 
            {label: 'Pod/Pdr', fieldName: 'ServicePointCode__c', type: 'text'}
        ]
    }
    @track caseRecord;

    @track mapFields = [{apiname:"CustomerName__c"}, {apiname:"CustomerLastName__c"}];

    showSingleRow;

    get isSendEmail(){
        return this.selectedSend=="E-Mail";
    }

    get isCartacea(){
        return this.selectedSend=="Posta Cartacea";
    }

    get selectedParentAsList(){
        return [this.selectedOrder];
    }
    get selectedParentAsListRow(){
        return [this.selectedOrder.Id];
    }

    connectedCallback(){
        getActivity({caseId: this.recordid}).then(result => {
            console.log("resu" + JSON.stringify(result));
            this.accountId = result.c.AccountId;
            this.typeDefaltValue = result.c.CopyType__c;
            this.tipoCopia = result.c.CopyType__c;
            this.orderIdPre = result.c.Order__c;
            this.selectedSend = result.c.SendMode__c;
            this.selectedActivity = result.c.Channel__c;
            this.caseRecord = {Id : this.recordid, AccountId : this.accountId};
            if(result.c.channel__c == 'Sportello'){
                this.showButtonPreview = true;
                this.isinboundchannel = false;
            }
            else{
                this.showButtonPreview = false;
                this.isinboundchannel = true;
            }
            if(result.c.CopyType__c != null && result.c.CopyType__c != undefined){
                this.getOrderParent(result.c.CopyType__c);
            }
        });
       // this.getOrderParent();

    }

    get firstRowChild(){
        console.log("sel row Child")
        console.log(this.selectedrowchild?.length ? null : this.selectedrowchild[0])
        if(!this.selectedrowchild?.length)  return null;
        if(!this.selectedrowchild[0].Contact__r) this.selectedrowchild[0].Contact__r={Email : ""};
        return this.selectedrowchild[0];
    }

    get isRec(){
        return this.tipoCopia == "Copia della registrazione";
    }

    getMapFields(){
        let mFields = new Map();
        //    constructor(label, apiname, required, disabled, value) {
        mFields.set("Copia contratto firmato",
            [
                new fieldData(null, "CustomerName__c" ),
                new fieldData(null, "CustomerLastName__c" ),
                new fieldData(null, "CustomerFiscalCode__c" ),
                new fieldData(null, "CustomerVATNumber__c" )
                
            ]
        )
        this.mapFields = mFields.get(this.tipoCopia);
    }

    get isFirmato(){
        return this.tipoCopia == "Copia contratto firmato";
    }

    changeValueTipo(event){
        this.tipoCopia = event.detail.value;
        //this.getMapFields();
        console.log('*****:' + event.detail.value);
        this.selectedOrder = null;
        this.showParentList = false;
        this.showChildList2 = false;
        this.showChildList = false;

        this.getOrderParent(event.detail.value);

    }

    changeValueTipoAttivita(event){
        this.selectedActivity = event.detail.value;
        if(event.detail.value == 'Sportello'){
            this.showButtonPreview = true;
            this.isinboundchannel = false;
        }
        else{
            this.showButtonPreview = false;
            this.isinboundchannel = true;
        }
    }

    changeValueTipoAttivita2(event){
        this.selectedSend = event.detail.value;
    }


    catchFieldsToSave(Case){

        this.template.querySelectorAll("lightning-input-field")?.forEach(elem=>{
            if(elem.getAttribute("data-id")!=null){
                Case[elem.getAttribute("data-id")]= elem.value;
            }
        });
        console.log(Case);
        let address = this.getAddress();
        if(address){
            this.saveAddress(address, Case);
        }
        return Case;
    }

    selectedRowHandler(event){
        console.log('********:' + JSON.stringify(event.detail.selectedRows));
        this.selectedOrder = event.detail.selectedRows[0];
        this.showSingleRow=true;
        if(!this.selectedOrder){
            this.showChildList = false;
            this.selectedOrderValue = null;
            return;
        }

        getChild({orderId : event.detail.selectedRows[0].Id}).then(response =>{
            response.forEach(elem=>elem.ServicePointCode__c=elem?.ServicePoint__r?.ServicePointCode__c);
            this.orderChildList = response;
            this.showChildList = true;
            if(this.tipoCopia == 'Copia della registrazione'){
                console.log('Try:Copia');
                this.selectedrowchild = this.orderChildList;
                this.showChildList2 = false;
                this.ismessagevisible = true;
                this.typeActivity = true;
                //this.showButtonPreview = false;
                //this.isinboundchannel = false;
            }
            else{
                this.showChildList2 = true;
                this.ismessagevisible = false;
                this.typeActivity = false;
               // this.showButtonPreview = false;
                //this.isinboundchannel = true;
            }
        });


    }
    handlePreview(event){
        try{
            let previewButton = event.target;
            previewButton.disabled=true;
            
           // this.loading = true;
            var formParams = {
                mode : 'Preview',
                Archiviato : 'N',
            };
            
            previewDocumentFile({
                recordId: this.selectedOrder.Id,
                context: 'Order',
                formParams: JSON.stringify(formParams)
            }).then(result => {
                var resultParsed = JSON.parse(result);
                if(resultParsed.code === '200' || resultParsed.code === '201'){
                    if(resultParsed.result === '000'){
                        var base64 = resultParsed.base64;
                        var sliceSize = 512;
                        base64 = base64.replace(/^[^,]+,/, '');
                        base64 = base64.replace(/\s/g, '');
                        var byteCharacters = window.atob(base64);
                        var byteArrays = [];

                        for ( var offset = 0; offset < byteCharacters.length; offset = offset + sliceSize ) {
                            var slice = byteCharacters.slice(offset, offset + sliceSize);
                            var byteNumbers = new Array(slice.length);
                            for (var i = 0; i < slice.length; i++) {
                                byteNumbers[i] = slice.charCodeAt(i);
                            }
                            var byteArray = new Uint8Array(byteNumbers);

                            byteArrays.push(byteArray);
                        }

                        this.blob = new Blob(byteArrays, { type: 'application/pdf' });

                        const blobURL = URL.createObjectURL(this.blob);
                        //this.loading = false;
                        this[NavigationMixin.Navigate](
                            {
                                type: 'standard__webPage',
                                attributes: {
                                    url: blobURL
                                }
                            }
                        );
                       // this.previewExecuted = true;
                    }else{
                        //this.loading = false;
                        this.showMessage('Attenzione',resultParsed.message,'error');
                    }
                }else{
                   // this.loading = false;
                    this.showMessage('Attenzione','Errore nella composizione del plico','error');
                }
               // this.isPrintButtonDisabled = false;
               previewButton.disabled=false;
            })
            .catch(error => {
               // this.loading = false;
                console.error(error);
            });
        }catch(error){
            console.error();
        }
       // this.isPrintButtonDisabled = false;
    }

    selectChild(event){
        this.ordChild  = event.detail.selectedRows[0];
    }

    getOrderParent(type){
        console.log('***ACC:' + this.accountId);
        getParent({accountId : this.accountId,tipo : type}).then(response =>{
            if(response != null && response.length != 0){
                this.ordersList = response;
                console.log('*****1:' +JSON.stringify(response));
                this.showParentList = true;
                for(var i=0; i<response.length; i++){
                    console.log('*****2:' + this.orderIdPre);
                    console.log('*****22:' + response[i].Id);
                    if(this.orderIdPre == response[i].Id){
                        console.log('*****3');
                        var lis = [];
                        lis.push(response[i].Id);
                        this.selectedOrderValue = lis;
                        this.showSingleRow=true;
                        this.selectedOrder = response[i];
                        getChild({orderId : response[i].Id}).then(response =>{
                            response.forEach(elem=>elem.ServicePointCode__c=elem?.ServicePoint__r?.ServicePointCode__c);
                            this.orderChildList = response;
                            this.showChildList = true;
                            if(this.tipoCopia == 'Copia della registrazione'){
                                console.log('Try:Copia');
                                this.selectedrowchild = this.orderChildList;
                                this.showChildList2 = false;
                                this.ismessagevisible = true;
                                this.typeActivity = true;
                                //this.showButtonPreview = false;
                                //this.isinboundchannel = false;
                            }
                            else{
                                this.showChildList2 = true;
                                this.ismessagevisible = false;
                                this.typeActivity = false;
                               // this.showButtonPreview = false;
                                //this.isinboundchannel = true;
                            }
                        });
                    }
                }
                console.log('*****4');
                this.showParentList = true;
            }
            else{
                const event = new ShowToastEvent({
                    message: 'Ordini non Trovati per il Tipo Selezionato',
                    variant: 'warning',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
            }
        });


    }

    handleConfirm(){

        console.log('*****:' + this.tipoCopia);
        let Case = this.catchFieldsToSave({Id: this.recordid});
        if(this.tipoCopia != 'Copia della registrazione' && (this.selectedActivity === undefined ||  this.selectedActivity == null || this.selectedActivity == '' || (this.selectedActivity == 'Inbound' && (this.selectedSend === undefined ||  this.selectedSend == null || this.selectedSend == '') ))){
            const event = new ShowToastEvent({
                message: 'Popolare i campi Obbligatori',
                variant: 'error',
                mode: 'dismissable'
                });
                this.dispatchEvent(event);
        }else{
                confirmAction2({
                    c : Case,
                    accountId : this.accountId,
                    orderParentId : this.selectedOrder.Id,
                    tipoAttivita : this.selectedActivity,
                    tipoFirma : this.tipoCopia,
                    tipoSend : this.selectedSend
                }).then(response =>{
                    if(response == null || response == ''){
                        const event = new ShowToastEvent({
                            message: 'Puoi Continuare la lavorazione in autonomia',
                            variant: 'success',
                            mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.recordid,
                                    objectApiName: 'Case',
                                    actionName: 'view'
                                }
                            });
                        const closeclickedevt = new CustomEvent('closeaction');
                        this.dispatchEvent(closeclickedevt); 
                    }
                    else if(response == 'NoDocumenti'){
                        const event = new ShowToastEvent({
                            message: 'Allega il Documento per Continuare' ,
                            variant: 'warning',
                            mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                    }
                    else{
                        const event = new ShowToastEvent({
                            message: 'è stata creata la seguente activity :' + response    ,
                            variant: 'warning',
                            mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.recordid,
                                    objectApiName: 'Case',
                                    actionName: 'view'
                                }
                            });
                        const closeclickedevt = new CustomEvent('closeaction');
                        this.dispatchEvent(closeclickedevt); 
                    }
                });
            }
    }

    handleConfirmDraft(){

        console.log('*****:' + this.tipoCopia);
        let Case = this.catchFieldsToSave({Id: this.recordid});
        confirmAction2Draft({
            c : Case,
            accountId : this.accountId,
            orderParentId : this.selectedOrder.Id,
            tipoAttivita : this.selectedActivity,
            tipoFirma : this.tipoCopia,
            tipoSend : this.selectedSend
                }).then(response =>{
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordid,
                            objectApiName: 'Case',
                            actionName: 'view'
                        }
                    });
                        const closeclickedevt = new CustomEvent('closeaction');
                        this.dispatchEvent(closeclickedevt); 
        });
    
    }


    validateAddress(address) {
        console.log('validateAddress START');
        let errorMessages = [];
        let concatAddressErrorFields = '';

        //Validate address
        if(!address['Indirizzo Estero']){
            console.log('entra in if ind estero');
            if (!address['Flag Verificato']) {
                console.log('entra in flag verificato false ');
                //this.saveErrorMessage.push('E\' necessario verificare l\'indirizzo per poter procedere al salvataggio');
                errorMessages.push('E\' necessario verificare l\'indirizzo per poter procedere al salvataggio');
            }
        } else {
            console.log('entra in else ind estero ');

            if (address['Stato'] === undefined || address['Stato'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Stato, ');
            }
            if (address['Provincia'] === undefined || address['Provincia'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Provincia, ');
            }
            if (address['Comune'] === undefined || address['Comune'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Comune, ');
            }
            if (address['Via'] === undefined || address['Via'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Via, ');
            }
            if (address['Civico'] === undefined || address['Civico'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('Civico, ');
            }
            if (address['CAP'] === undefined || address['CAP'] === '') {
                concatAddressErrorFields = concatAddressErrorFields.concat('CAP, ');
            }
            if (concatAddressErrorFields !== '') {
                errorMessages.push('Per poter salvare popolare i seguenti campi di indirizzo: ' + concatAddressErrorFields.slice(0, -2));
            }
        }        

        if (errorMessages.length==0) {
            return {
                isValid: true
            };
        }
        else {
            return {
                isValid: false,
                errorMessage: errorMessages.join("; ")
            };
        }
    }

    saveAddress(address, Case) {
        let validity = this.validateAddress(address);
        if (validity.isValid) {
            this.populateCase(address, Case);
        }
        return validity;
    }

    populateCase(address, Case){
        Case["InvoicingStreetName__c"] = address['Via'];
        Case["InvoicingCity__c"] = address['Comune'];
        Case["InvoicingPostalCode__c"] = address['CAP'];
        Case["InvoicingCountry__c"] = address['Stato'];
        Case["InvoicingProvince__c"] = address['Provincia'];
        Case["InvoicingStreetNumberExtension__c"] =  address['Estens.Civico'];
        Case["InvoicingStreetNumber__c"] = address['Civico'];
        Case["InvoicingPlace__c"] = address['Localita'];
    }

    getAddress() {
        let address = this.template.querySelector('c-hdt-target-object-address-fields')?.handleAddressFields();
        if (address?.['Stato']=='Italy' || address?.['Stato']=='Italia'){
            address['Stato']=='ITALIA';
        }
        return address;
    }

    takeFormData(event){
        if(event.target.fieldName !== undefined){
            this.sectionDataToSubmit[event.target.fieldName] = event.target.value;
        }
        if(event.target.name !== undefined){
            this.sectionDataToSubmit[event.target.name] = event.target.value;
        }
    }

    handleAnnull(){
        cancelCase({caseId: this.recordid}).then(result => {
            console.log(result);
            const event = new ShowToastEvent({
                message: 'Case Annullato!',
                variant: 'success',
                mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordid,
                        objectApiName: 'Case',
                        actionName: 'view'
                    }
                });
                    const closeclickedevt = new CustomEvent('closeaction');
                    this.dispatchEvent(closeclickedevt); 
            }).catch(error => {
                console.log(error);
            });
    }




}