import { LightningElement,api,track,wire } from 'lwc';
import getStatements from '@salesforce/apex/HDT_LC_AccountStatementPicker.getStatements';
import getDocumentSelected from '@salesforce/apex/HDT_LC_AccountStatementPicker.getDocumentSelected';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';

const columns = [
    {
        label: '', type: 'button-icon', typeAttributes: {
            label: 'Aggiungi',
            variant: 'brand',
            name:'aggiungi',
            iconName:'utility:add',
            variant:'brand'
        }
    },
    { label: 'Conto Contrattuale', fieldName: 'contoContrattuale'},
    { label: 'Numero Documento', fieldName: 'xblnr'},
    { label: 'Numero Bollettino', fieldName: 'bollo'},
    { label: 'Totale Copertina', fieldName: 'totPagare' },
    { label: 'Tipo', fieldName: 'tipoDocDesc' },
    { label: 'Totale Documento', fieldName: 'totFattura'},
    { label: 'Residuo', fieldName: 'residuo'},
    { label: 'Residuo Canone Rai', fieldName: 'restituzioneCanoneRai'},
    { label: 'Data emissione', fieldName: 'bmItemDt'},
    { label: 'Data scadenza', fieldName: 'bmEndDt'},
    { label: 'Rateizzato', fieldName: 'rateizzato'},
    { label: 'Sollecitato', fieldName: 'sollecitato'},
    { label: 'Modalità di pagamento', fieldName: 'payment'},
    { label: 'Società', fieldName: 'socEmittenteDesc'},
    { label: 'Codice Tipo Documento', fieldName: 'tipoDoc'},
    { label: 'Codice Società Emittente', fieldName: 'socEmittente'},
];

const columnsDocumentSelected = [
    {
        label: '', type: 'button-icon', typeAttributes: {
            label: 'Elimina',
            variant: 'brand',
            name:'elimina',
            iconName:'utility:delete',
        }
    },
    { label: 'Conto Contrattuale', fieldName: 'ContractualAccount__c'},
    { label: 'Numero Documento', fieldName: 'DocumentNumber__c'},
    { label: 'Numero Bollettino', fieldName: 'Bill__c'},
    { label: 'Totale Copertina', fieldName: 'TotalCommunicationPayment__c' },
    { label: 'Tipo', fieldName: 'Type__c' },
    { label: 'Totale Documento', fieldName: 'Amount__c'},
    { label: 'Residuo', fieldName: 'Residue__c'},
    { label: 'Residuo Canone Rai', fieldName: 'TvFeeResidual__c'},
    { label: 'Modalità di pagamento', fieldName: 'PaymentMode__c'},
    { label: 'Società', fieldName: 'IssuingCompany__c'}
];

export default class HdtAccountStatementPicker extends LightningElement {
    @api contractAccount;
    @api billingProfileId;
    @api codiceCliente;
    @api caseId;
    @api processType;
    @api accountId;
    @api billingProblems;
    @track documents;
    @track wiredDocumentsResult;
    @track showSpinner = true;
    data = [];
    columns = columns;
    columnsDocumentSelected = columnsDocumentSelected;
    startDate;
    endDate;
    numeroDocumento;
    numeroBollettino;
    showTable = false;
    detailFields = ['Name'];
    @track filter;
    
    getDocuments(){
        getDocumentSelected({
            caseId:this.caseId
        }).then(data => {
            console.log(JSON.parse(data));
            console.log(data.length);
            if(data && data.length>0){
                this.documents = JSON.parse(data);
            }else{
                this.documents = undefined;
            }
        }).catch(err => {
            this.documents = undefined;
            console.log(err);
        });
    }
    
    connectedCallback(){
        console.log('contractAccount ' + this.contractAccount);
        console.log('billingProfileId ' + this.billingProfileId);
        console.log('codiceCliente ' + this.codiceCliente);
        console.log('caseId ' + this.caseId);
        console.log('processType ' + this.processType);
        console.log('accountId ' + this.accountId);
        this.filter = 'Account__c=\''+this.accountId+'\'';

        var today = new Date();
        this.endDate = this.formatDate(today);
        var month = today.getMonth()-36;
        today.setMonth(month);
        this.startDate = this.formatDate(today);
        if(this.contractAccount){
            this.data = this.getRecords();
        }else{
            this.showSpinner = false;
        }
        this.getDocuments();
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('actionName ' + actionName);
        console.log('row ' + JSON.stringify(row));
        if(actionName.localeCompare('aggiungi') == 0){
            this.addDocument(row);
        }else if(actionName.localeCompare('elimina') == 0){
            this.removeDocument(row);
        }
    }
    handleSelection(event){
        console.log('# from lookup: ' + event.detail.selectedId + ' - ' + event.detail.name + ' - ' + event.detail.code);
        this.contractAccount = event.detail.name
        this.billingProfileId = event.detail.selectedId;
    }
    handleSubmit(){
        this.startDate = this.template.querySelector("lightning-input[data-id=fromDate]").value;
        this.endDate = this.template.querySelector("lightning-input[data-id=toDate]").value;
        var codContoContratto = this.contractAccount;
        this.numeroDocumento = this.template.querySelector("lightning-input[data-id=numeroDocumento]").value;
        this.numeroBollettino = this.template.querySelector("lightning-input[data-id=numeroBollettino]").value;
        if((codContoContratto == "" || !codContoContratto) && (this.numeroDocumento == "" || !this.numeroDocumento) && (this.numeroBollettino == "" || !this.numeroBollettino)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Inserire almeno uno dei seguenti parametri: 1 Codice Conto Contrattuale; 2 Numero Documento; 3 Numero Bollettino',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }else{
            this.getRecords();
        }
    }
    getRecords(){
        this.showSpinner=true;
        this.data =[];
        var fromDate = this.transformDate(this.startDate);
        var toDate = this.transformDate(this.endDate);
        var codCli = this.codiceCliente;
        var codContoContratto = this.contractAccount;
        var numeroDocumento = this.numeroDocumento;
        var numeroBollettino = this.numeroBollettino;
        try{
            var params = {};
            params.codCli = codCli;
            params.codContoContratto = codContoContratto;
            if(fromDate){
                params.fromDate = fromDate;
            }
            if(toDate){
                params.toDate = toDate;
            }
            if(numeroDocumento){
                params.xblnr = numeroDocumento;
            }
            if(numeroBollettino){
                params.bollo = numeroBollettino;
            }
            console.log(JSON.stringify(params));
            getStatements
            ({
                params:JSON.stringify(params)
            }).then(data => {
                console.log(JSON.parse(data));
                console.log(data.length);
                if(data && data.length>0){
                    this.data = JSON.parse(data);
                    this.showTable = true;
                }else{
                    this.showTable = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Attenzione',
                            message: 'Nessun Documento trovato. Cambiare i parametri di ricerca e premere il tasto Ricerca',
                            variant: 'error'
                        })
                    );
                }
                
            }).catch(err => {
                this.showTable = false;
                console.log(err);
            });
            
        }catch(error){
            console.error(error);
        }
        this.showSpinner=false;
    }

    formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
    
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
    
        return [year, month, day].join('-');
    }
    formatDateForInsert(date){
        if(date!= null && date != ""){
            var dateSplitted = [];
            dateSplitted = date.split('/');
            return [dateSplitted[2],dateSplitted[1],dateSplitted[0]].join('-');
        }
        else
            return null;
    }

    transformDate(date){
        if(date!= null && date != ""){
            var dateSplitted = [];
            dateSplitted = date.split('-');
            return [dateSplitted[2],dateSplitted[1],dateSplitted[0]].join('/');
        }
        else
            return null;
    }
    removeDocument(row){
        this.showSpinner=true;
        if(row.Id != null && row.Id != ''){
            deleteRecord(row.Id)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Documento cancellato',
                        variant: 'success'
                    })
                );
                this.getDocuments();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        } 
        this.showSpinner=false;
    }
    addDocument(row){
        try{
            var alreadyExist = false;
            this.showSpinner=true;
            if(row['rateizzato'] != null && row['rateizzato'] === 'X' ){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Non è possibile selezionare documenti rateizzati',
                        variant: 'error'
                    })
                );
                this.showSpinner=false;
                return null;
            }
            if(row['tipoDoc'] != null && row['tipoDoc'] === 'RATEIZZAZIONI' && this.processType === 'Piano Rateizzazione'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Per questo processo non è possibile selezionare documenti di tipo RATEIZZAZIONE',
                        variant: 'error'
                    })
                );
                this.showSpinner=false;
                return null;
            }
            if(row['xblnr'] != null && row['xblnr'] != '' && this.documents){
                /*var document = this.documents.find(function(post, index) {
                    if(post.DocumentNumber__c == row['xblnr'])
                        return true;
                });*/
                var documentList = this.documents.filter(function(item){
                    return item.DocumentNumber__c == row['xblnr']});
                console.log(documentList);
                documentList.forEach(document => {
                    if(document['ExpirationDate__c'] === this.formatDateForInsert(row['bmEndDt'])){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Attenzione',
                                message: 'Questo documento è stato già selezionato',
                                variant: 'error',
                            })
                        );
                        this.showSpinner=false;
                        alreadyExist = true;
                        return null;
                    }
                });
                if(alreadyExist)
                    return null;
                /*if(document){
                    if(document['ExpirationDate__c'] === this.formatDateForInsert(row['bmEndDt'])){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Attenzione',
                                message: 'Questo documento è stato già selezionato',
                                variant: 'error',
                            })
                        );
                        this.showSpinner=false;
                        return null;
                    }
                }*/
            }
            if(this.documents){
                var ca = this.documents[0].ContractualAccount__c;
                var selectedCa = row.contoContrattuale;
                if(this.processType === 'Piano Rateizzazione' && ca != selectedCa){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Attenzione',
                            message: 'Per questo processo non è possibile selezionare Documenti afferenti a CA differenti.',
                            variant: 'error',
                        })
                    );
                    this.showSpinner=false;
                    return null;
                }
            }
            console.log(row['bmEndDt'] + ' ' + this.formatDateForInsert(row['bmEndDt']));
            var fields = {
                'Name' : row.xblnr,
                'DocumentNumber__c' : row.xblnr, 
                'Bill__c' : row.boll, 
                'Type__c' : row.tipoDocDesc,
                'IssueDate__c' : this.formatDateForInsert(row.bmItemDt),
                'ExpirationDate__c' : this.formatDateForInsert(row.bmEndDt),
                'Amount__c' : row.totFattura,
                'DocumentResidue__c' : row.residuo,
                'Extension__c' : row.sollecitato,
                'PaymentMode__c' : row.payment,
                'TvFeeResidual__c' : row.restituzioneCanoneRai,
                'IssuingCompany__c' : row.socEmittenteDesc,
                'ContractualAccount__c' : row.contoContrattuale,
                'TotalCommunicationPayment__c' : row.totPagare,
                'Case__c' : this.caseId,        
            };
            var objRecordInput = {'apiName' : 'DocumentSelected__c', fields};
            createRecord(objRecordInput).then(response => {
                this.showSpinner=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Documento selezionato con successo',
                        variant: 'success'
                    })
                );
                this.getDocuments();
            }).catch(error => {
                this.showSpinner=false;
                new ShowToastEvent({
                    title: 'Errore',
                    message: 'Non è possibile creare questo documento',
                    variant: 'error'
                })
            });
            
        }catch(error){
            console.error(error);
        }
    }

    //Metodo per Variazioni
    @api
    checkBillingProblems(){

        console.log('Check Started');
        console.log('BillingProblem--> '+this.billingProblems);
        console.log('Documents--> '+this.documents);

        if(this.billingProblems && (this.documents === null || this.documents === undefined)){

            this.dispatchEvent(new ShowToastEvent({
                title: 'Errore',
                message: 'Necessario selezionare almeno una fattura',
                variant: 'error'
                })
            );

            return true;

        } else {

            return false;

        }
    }

    @api
    getBillingProfileId(){
        return this.billingProfileId;
    }

}