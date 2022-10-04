import {api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HdtRecordEditFormFlow from 'c/hdtRecordEditFormFlow';

export default class HdtRecordEditFormFlowAdvanced extends HdtRecordEditFormFlow {

    @api processType="Rifiuti Hergo";
    @api recordId;
    @api saveButton;
    @api objectName;
    @api labelSaveButton;
    @api previousButton;
    @api labelPreviousButton;
    @api cancelButton;
    @api draftButton;
    @api labelDraftButton;
    @api density;
    @api recordType;
    @api saveInDraft;
    @api cancelCase;
    @api nextStep;
    @api showReadOnly;
    @api labelInputSection;
    @api labelReadOnlySection;
    @api variantSaveButton;
    @api outputId;
    @api freeWithdrawConfig;
    @api lastWithdrawDate;
    _checkResidente;
    _typeOperation;
    _withdrawConfiguration;
    isCubatureLimited;
    cubatureLimit;
    _checkOnLoadHergo = false;
    disableMaterialButton = true;
    _recentWithdrawal = false;

    virtualChange(event){
        console.log(" ### event -> " + event);

        if(event.target.fieldName == 'ClientTypology__c'){
            this._checkResidente = event.target.value == 'Domestico';
        }

        if(event.target.fieldName == 'TypeOperation__c'){
            this._typeOperation = event.target.value;
        }

        if(event.target.fieldName == 'ClientTypology__c' || event.target.fieldName == 'TypeOperation__c'){
            this.template.querySelector("[data-id='WithdrawalFee__c']").value = false;
        }

        this.checkConfiguration(event);
        
    }


    handleOnLoad(event){
        super.handleOnLoad(event);
        if(this.firstColumn.length + this.secondColumn.length == this.template.querySelectorAll("lightning-record-edit-form lightning-input-field").length && !this._checkOnLoadHergo){
            this._checkOnLoadHergo = true;
            this._checkResidente = this.template.querySelector("[data-id='ClientTypology__c']").value == 'Domestico';
            this._typeOperation = this.template.querySelector("[data-id='TypeOperation__c']").value;
            this.checkConfiguration(event);
        }

    }

    checkConfiguration(event){
        this._recentWithdrawal = false;

        if(!(this._typeOperation && this.template.querySelector("[data-id='ClientTypology__c']").value) ){
            this.disableMaterialButton = true;
            return;
        }

        this._withdrawConfiguration = null;
        this.freeWithdrawConfig.forEach((currentItem)=>{
            if(currentItem.TypeOperation__c?.includes(this._typeOperation)){ // multiselect picklist
                this._withdrawConfiguration = currentItem;
            }
        });  

        console.log("New Config ")
        console.log(this._withdrawConfiguration);

        if(!this._withdrawConfiguration){
            if(event.target.fieldName == 'ClientTypology__c' || event.target.fieldName == 'TypeOperation__c'){
                this.showMessage('Attenzione','Non è stata trovata una corrispondenza tra la combinazione Comune / Tipo Intervento e la tabella di Configurazione Ritiri Gratuiti. Aprire segnalazione per notificare la problematica.','error');
                this.template.querySelector("[data-id='WithdrawalFee__c']").value = true;
            }
        }else{

            if(this._withdrawConfiguration.FreeWithdrawCalculation__c == 'N'){
                this.isCubatureLimited = 'N';
                this.disableMaterialButton = false;
                this.cubatureLimit=null;
            }else{
                this.isCubatureLimited = 'Y';
                this.disableMaterialButton = false;

                let n = this._checkResidente? this._withdrawConfiguration.ToBePaidWithinMonthsDomestic__c : this._withdrawConfiguration.ToBePaidWithinMonthsNotDomestic__c;
                console.log('### DataUltimoRitiro -> ' + this.lastWithdrawDate);
                var dateSubtracted =  this.getDateSubtracted(new Date(),n);
                console.log('### DataUltimoRitiro-nMesi -> ' + dateSubtracted);

                if(this.lastWithdrawDate > dateSubtracted){
                    this.showMessage('Attenzione', 'Ritiro a pagamento causa ultimo ritiro più recente di '+ n +' mesi','error');
                    this.template.querySelector("[data-id='WithdrawalFee__c']").value = true;
                    this._recentWithdrawal = true;
                }else{
                    this.cubatureLimit = this._checkResidente? this._withdrawConfiguration.ToPayIfVolumeEqualOrHigherDom__c : this._withdrawConfiguration.ToPayIfVolumeEqualOrHigherNotDom__c; 
                }

            }
        }
    }

    handleClose(event){
        console.log('###Close Event >>> ' + JSON.stringify(event.detail));
        this.template.querySelector("[data-id='MaterialDescription__c']").value = event.detail.label;
        if(!this._recentWithdrawal){
            this.template.querySelector("[data-id='WithdrawalFee__c']").value = event.detail.needPayment;
        }
    }


    showMessage(title, message, variant) {
        const toastErrorMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastErrorMessage);
    }

    getDateSubtracted(today, numberToSubtract) {
        let month = '' + (today.getMonth() + 1);
        let day = '' + today.getDate();
        let year = today.getFullYear();

        if (day.length < 2) 
            day = '0' + day;
        let monthUpdated = month - numberToSubtract;

        if (monthUpdated < 10) 
            monthUpdated = '0' + monthUpdated;
            
        return [year, monthUpdated, day].join('-');
    }
}