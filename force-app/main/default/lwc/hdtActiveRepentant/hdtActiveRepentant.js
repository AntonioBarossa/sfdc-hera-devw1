import { LightningElement , api, track } from 'lwc';
import getPeriods from '@salesforce/apex/HDT_LC_ActiveRepentant.getPeriods';
import getTerms from '@salesforce/apex/HDT_LC_ActiveRepentant.getTerms';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class HdtActiveRepentant extends LightningElement {

    @api order; 
    @track missedDueDate;
    @track limitDateX;
    @track limitDateY;
    @track period;
    resultsFound = false;

    handleRepentant(){
        console.log('order ->' + this.order.ServicePoint__r.SupplyCity__c);
        console.log('Richiesta Subentro ');

        getPeriods({comune: this.order.ServicePoint__r.SupplyCity__c, sottotipo:'Subentro'}) //TODO
        .then(data => {
                if(data && data.lenght != 0){
                    console.log('data ' + data[0].Id);
                    this.period = data[0];
                    this.checkData(data[0]);
                }
        }).catch(error => {
            console.log('#ErrorGetPeriods -> '+JSON.stringify(error));
        })
        checkMissedDue();
    } 

    getLimitDateX(data){
        if(data.PeriodXCriteria__c == 'Data'){
            var anno = data.EffectiveDate__c.substring(0,4);
            anno = anno ++;
            this.limitDateX = new Date(anno += '-06-30');
         }else {
            this.limitDateX = new Date(data.EffectiveDate__c);
            this.limitDateX.setDate(this.limitDateX.getDate() + data.DaysX__c);
        }
        console.log('this.limitDateX -> ' + this.limitDateX);
    }

    getLimitDateY(periodYCriteria, daysY){
        this.limitDateY = new Date();
        if(periodYCriteria == 'Mesi fissi'){
            this.limitDateY.setMonth(this.limitDateX.getMonth() + daysY);
        }else { //if(periodYCriteria == 'Giorni fissi')
            this.limitDateY.setDate(this.limitDateX.getDate() + daysY);
        }
        console.log('getLimitDateY -> ' + this.limitDateY);
    }

    calculateMissedDue(declarationDate) {
        var anno = this.order.Sale__r.CreatedDate.substring(0,4);
        getTerms({comune: this.order.ServicePoint__r.SupplyCity__c})
        .then(data => {
                if(data && data.lenght != 0){
                    data.forEach(obj => {
                        var actualDate = new Date(anno+'-'+obj.Month__c +'-'+ obj.Day__c);
                        console.log('actualDate ->' + actualDate);
                        if(declarationDate < actualDate < this.limitDateX){
                            this.missedDueDate = actualDate;
                            this.resultsFound = true;
                            this.checkMissedDue();
                        }
                    });
                }
        }).catch(error => {
            console.log('#ErrorGetTerms -> '+JSON.stringify(error));
        })
        
    }

    checkData(data){

        console.log('sale ' + this.order.Sale__c);
        console.log('createdDate ' + this.order.Sale__r.CreatedDate);
        var declarationDate = new Date(this.order.Sale__r.CreatedDate.substring(0,10));
       
        this.getLimitDateX(data);

        if(declarationDate < this.limitDateX){
            console.log('periodo ravvedibile');
            this.getLimitDateY(data.PeriodYCriteria__c, data.DaysY__c); //END
            return;
        }else{ //periodo non ravvedibile
            console.log('periodo non ravvedibile');
            this.getLimitDateY(data.PeriodYCriteria__c, data.DaysY__c);
        }

        if(declarationDate > this.limitDateY){
            console.log('non sussiste mancato dovuto');
            this.showMessage('Attenzione!', this.period.PopupZText__c ,' error');
            return;

        }else{
            console.log('mancato dovuto');
            this.calculateMissedDue(declarationDate);
            this.showMessage('Attenzione!', this.period.PopupYText__c ,' error');
        }
    }

    showMessage(title,message,variant)
    {
        this.loading = false;
        const toastErrorMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
    this.dispatchEvent(toastErrorMessage);
    }

    checkMissedDue() {

       if(!this.resultsFound){
        this.dispatchEvent(CustomEvent("check_missed_due", {detail:{}}));
       }else{
        this.dispatchEvent(CustomEvent("check_missed_due", {detail:{
            dateX: this.limitDateX, 
            dateY: this.limitDateY, 
            missedDue: this.missedDueDate
        }}));
       }
      }

}