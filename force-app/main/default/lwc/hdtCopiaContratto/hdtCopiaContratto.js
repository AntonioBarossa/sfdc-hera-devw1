import { LightningElement, api, track , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import previewDocumentFile from '@salesforce/apex/HDT_LC_DocumentSignatureManager.previewDocumentFile';
import getParent from '@salesforce/apex/HDT_LC_CopiaContratto.getAccountOrder';
import getChild from '@salesforce/apex/HDT_LC_CopiaContratto.getOrderChild';
import confirmAction2 from '@salesforce/apex/HDT_LC_CopiaContratto.confirmAction';


export default class HdtCopiaContratto extends NavigationMixin(LightningElement){
    @api processtype;
    @api objectName = 'Case';
    @api recordid;
    @api accountId;
    @api saveButton;
    @api showOrder = false;
    @api cancelButton;
    @api draftButton;
    @api selectedrowchild = [];
    @api acceptedFormats = ['.pdf', '.png'];
    @api statoApp = 'Nessuna Richiesta Inviata';
    @api saveInDraft;
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

    @track columns = [
        {label: 'Name', fieldName: 'Name', type: 'text'},
        {label: 'Order Number', fieldName: 'OrderNumber', type: 'text'},
        {label: 'Status', fieldName: 'Status', type: 'text'}        
    ];
    @track columnsChild = [
        {label: 'Order Number', fieldName: 'OrderNumber', type: 'text'},
        {label: 'Status', fieldName: 'Status', type: 'text'}        
    ];

    connectedCallback(){

        this.getOrderParent();

    }

    changeValueTipo(event){
        this.tipoCopia = event.detail.value;
        console.log('*****:' + event.detail.value);
        if(event.detail.value == 'Copia della registrazione'){
            console.log('Try:Copia');
            this.selectedrowchild = this.orderChildList;
            this.showChildList2 = false;
            this.typeActivity = true;
            this.showButtonPreview = false;
        }
        else{
            this.showChildList2 = true;
            this.typeActivity = false;
            this.showButtonPreview = true;
        }
    }

    changeValueTipoAttivita(event){
        this.selectedActivity = event.detail.value;
    }

    selectedRowHandler(event){
        console.log('********:' + JSON.stringify(event.detail.selectedRows));
        this.selectedOrder = event.detail.selectedRows[0];

        getChild({orderId : event.detail.selectedRows[0].Id}).then(response =>{
            this.orderChildList = response;
            this.showChildList = true;
            
        });


    }
    handlePreview(){
        try{
            
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

    getOrderParent(){
        getParent({accountId : this.accountId}).then(response =>{
            this.ordersList = response;
        });


    }

    handleConfirm(){

        if(this.tipoCopia != 'Copia della registrazione' && (this.selectedActivity === undefined ||  this.selectedActivity == null || this.selectedActivity == '')){
            const event = new ShowToastEvent({
                message: 'Popolare i campi Obbligatori',
                variant: 'error',
                mode: 'dismissable'
                });
                this.dispatchEvent(event);
        }else{
            confirmAction2({
                caseId : this.recordid,
                accountId : this.accountId,
                orderParentId : this.selectedOrder.Id,
                tipoAttivita : this.selectedActivity,
                tipoFirma : this.tipoCopia
            }).then(response =>{
                if(response == null || response == ''){
                    const event = new ShowToastEvent({
                        message: 'Puoi Continuare la lavorazione in autonomia',
                        variant: 'success',
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
                }
                const closeclickedevt = new CustomEvent('closeaction');
            });
        }





    }





}