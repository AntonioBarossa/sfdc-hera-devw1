import { LightningElement, api, track } from "lwc";
import getPeriods from "@salesforce/apex/HDT_LC_ActiveRepentant.getPeriods";
import getTerms from "@salesforce/apex/HDT_LC_ActiveRepentant.getTerms";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class HdtActiveRepentant extends LightningElement {
    @track missedDueDate;
    @track limitDateX;
    @track limitDateY;
    @track period;
    skipCheck = false;
    disabled = false;

    @api dateDecorrenza;
    @api dateDichiarazione;
    @api city;

    buttonPressed() {
        this.disabled=true;
        this.dispatchEvent(CustomEvent("request_data"));
        return;
    }

    @api validateDate(dateDecorrenza) {
        //valida controllo, dateDecorrenza non può essere futura
        if(this.disabled)   return true;//algoritmo in fase di calcolo
        if(this.skipCheck)  return false;//controllo non necessario
        return !(this.dateDecorrenza && this.dateDecorrenza == dateDecorrenza);//controlla che la data decorrenza sia popolata e aggiornata
    }

    @api startActiveRepentant(dateDecorrenza) {
        if (dateDecorrenza && new Date(dateDecorrenza).getTime() < new Date().getTime()) {
            this.dateDecorrenza = dateDecorrenza;
            this.handleRepentant();
        } else {
            this.showMessage(
                "Attenzione!",
                dateDecorrenza? "La data decorrenza non può essere futura" : "Popolare Data Decorrenza",
                "error"
            );
            this.dateDecorrenza=null;
            this.disabled=false;
        }
    }

    async handleRepentant() {
        console.log("order ->" + this.city);
        console.log("Richiesta Subentro ");

        try{
            let data = await getPeriods({ comune: this.city, sottotipo: "Subentro" });
            let terms = await getTerms({ comune: this.city });
            if (data?.length) {
                this.skipCheck=false;
                console.log("data " + data[0].Id);
                this.period = data[0];
                this.checkData(data[0], terms);
            }else{
                throw 'Data not found!';
            }
        }catch(error) {
            console.log("#ErrorGetPeriods -> " + JSON.stringify(error));
            this.skipCheck=true;
        }finally{
            this.finish();
        }
        //this.checkMissedDue();
    }

    getLimitDateX(data) {
        this.limitDateX = new Date(this.dateDecorrenza);
        if (data.CriteriaX__c == "Data") {
            //var anno = data.EffectiveDate__c.substring(0,4);
            let anno = this.limitDateX.getFullYear();
            anno++;
            this.limitDateX = new Date((anno += "-06-30"));
        } else {
            //this.limitDateX = new Date(data.EffectiveDate__c);
            this.limitDateX = new Date(this.dateDecorrenza);
            this.limitDateX.setDate(
                this.limitDateX.getDate() + parseInt(data.DayX__c, 10)
            );
        }
        console.log("this.limitDateX -> " + this.limitDateX);
    }

    getLimitDateY(CriteriaY, daysY) {
        this.limitDateY = new Date(this.limitDateX);
        if (CriteriaY == "Mesi fissi") {
            this.limitDateY.setMonth(
                this.limitDateX.getMonth() + parseInt(daysY, 10)
            );
        } else {
            this.limitDateY.setDate(
                this.limitDateX.getDate() + parseInt(daysY, 10)
            );
        }
        console.log("getLimitDateY -> " + this.limitDateY);
    }

    calculateMissedDue(data, declarationDate) {
        var anno = this.dateDichiarazione.substring(0, 4);

        if (data?.lenght) {
            data.forEach((obj) => {
                var actualDate = new Date(
                    anno + "-" + obj.Month__c + "-" + obj.Day__c
                );
                console.log("actualDate ->" + actualDate);
                if (declarationDate.getTime() < actualDate.getTime() < this.limitDateX.getTime()) {
                    console.log("mancato dovuto")
                    this.missedDueDate = actualDate;
                }
            });
        }
    }

    checkData(data, terms) {
        var declarationDate = new Date(this.dateDichiarazione.substring(0, 10));

        this.getLimitDateX(data);
        this.getLimitDateY(data.CriteriaY__c, data.DayY__c);

        if (declarationDate.getTime() < this.limitDateX.getTime()) {
            console.log("periodo precedente a x");
            this.periodType ="X";
            return;
        }

        if (declarationDate.getTime() > this.limitDateY.getTime()) {
            console.log("Periodo non ravv Z");
            this.periodType ="Z";
            this.showMessage("Attenzione!", this.period.PopupZ__c, " error");
            return;
        } else {
            console.log("Periodo Ravvedibile Y");
            this.periodType ="Y";
            this.calculateMissedDue(terms, declarationDate);
            this.showMessage("Attenzione!", this.period.PopupY__c, " error");
        }
    }

    showMessage(title, message, variant) {
        this.loading = false;
        const toastErrorMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastErrorMessage);
    }

    finish() {
        this.dispatchEvent(
            CustomEvent("end_algorithm", {
                detail: {
                    dateX: this.limitDateX,
                    dateY: this.limitDateY,
                    missedDue: this.missedDueDate,
                    period: this.periodType
                }
            })
        );
        this.limitDateX=null;
        this.limitDateY=null;
        this.missedDueDate=null;//reset data to avoid conflicts
        this.disabled=false;
    }
}
