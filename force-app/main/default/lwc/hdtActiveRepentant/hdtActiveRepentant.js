import { LightningElement, api, track, wire } from "lwc";
import getPeriods from "@salesforce/apex/HDT_LC_ActiveRepentant.getPeriods";
import getTerms from "@salesforce/apex/HDT_LC_ActiveRepentant.getTerms";
import getTables from "@salesforce/apex/HDT_LC_ActiveRepentant.getTables";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE} from "lightning/messageService";
import BUTTONMC from "@salesforce/messageChannel/flowButton__c";

class outputData{
    constructor(dateX, dateY, missedDue, declineSupport, refuseSupport, bloccoCalcolo, dateDecorrenza, dateDichiarazione) {
        this.dateX = dateX;
        this.dateY=dateY;
        this.missedDue = missedDue;
        this.declineSupport=declineSupport? declineSupport : refuseSupport? refuseSupport : null;
        this.bloccoCalcolo=bloccoCalcolo;
        this.dateDecorrenza=dateDecorrenza;
        this.dateDichiarazione=dateDichiarazione;
    }
}//Prendere anche data dichiarazione in maniera dinamica

export default class HdtActiveRepentant extends LightningElement {
    @track missedDueDate;
    @track limitDateX;
    @track limitDateY;
    @track period;
    @track termsAdministration;
    @track cityData;//Comuni non affidatari
    skipCheck = false;
    disabled = false;
    loading=0;
    formLoading= true;

    @api dateDecorrenza;
    @api dateDichiarazione;
    @api city;
    @api sottotipo;

    //variables from flow
    @api recordId;
    @api objectApiName;
    @api outputWrp={};
    @api sessionid;
    @api companyOwner;

    @wire(MessageContext)
	messageContext;

    get showSpinner(){
        return this.formLoading || this.loading>0;
    }

    get isCompanyMms(){
        return "MMS".localeCompare(this.companyOwner) === 0;
    }

    get isCase(){
        return this.objectApiName=="Case";
    }

    loadedForm(){
        this.formLoading=false;
    }

    connectedCallback(){
        this.loading++;
        this.getTablesConfig();
        if(this.recordId){
            this.subscribeMC();
            const oldWrpStr = window.sessionStorage.getItem(this.sessionid);
            if(this.sessionid && oldWrpStr){
                try{
                    this.outputWrp = JSON.parse(oldWrpStr);
                }catch(e){
                    console.log(e);
                }
            }
        }
    }

    buttonPressed() {
        this.disabled=true;
        if(this.recordId){
            //flow
            let decorrenza =this.template.querySelector("[data-id='EffectiveDate__c']")?.value;
            let dichiarazione =this.template.querySelector("[data-id='DeclarationDate__c']")?.value;
            if(dichiarazione){     this.startActiveRepentant(decorrenza, dichiarazione);  }  
            else{   this.showMessage("Attenzione!", "Popolare Data Dichiarazione", "error");this.disabled=false;    }
        }else{
            //wizard Attivazioni
            this.dispatchEvent(CustomEvent("request_data"));
        }
        return;
    }

    @api validateDate(dateDecorrenza, dateDichiarazione) {
        //valida controllo, dateDecorrenza non può essere futura
        if(this.disabled)   return true;//algoritmo in fase di calcolo
        if(this.skipCheck)  return false;//controllo non necessario
        return !((this.dateDecorrenza && this.dateDecorrenza == dateDecorrenza) && (this.dateDichiarazione && this.dateDichiarazione?.startsWith(dateDichiarazione)));//controlla che la data decorrenza sia popolata e aggiornata
    }

    @api validate(){   
        console.log("event catched   "+this.eventButton);
        this.unsubscribeToMessageChannel();
        let decorrenza =this.template.querySelector("[data-id='EffectiveDate__c']")?.value;
        let dichiarazione =this.template.querySelector("[data-id='DeclarationDate__c']")?.value;
        let message, isValid=false;
        if('cancel' != this.eventButton){
            if([...this.template.querySelectorAll("lightning-input-field")].every(el=> (!el.required || el.value))){
                isValid = !this.validateDate(decorrenza, dichiarazione);
            }else{
                message = 'Compilare campi obbligatori';
            }
            //let 
            this.outputWrp=this.outputObject();
            if(!isValid){
                window.sessionStorage.setItem(this.sessionid, JSON.stringify(this.outputWrp));
                message = message? message : 'Verificare il ravvedimento operoso prima di procedere';
            }else{
                window.sessionStorage.removeItem(this.sessionid);
            }
        }else{
            isValid=true;
        }
        return { isValid : isValid, 
            errorMessage: message? message : null
        };
    }

    outputObject(){
        return new outputData(
            this.template.querySelector("[data-id='OnerousReviewableStartDate__c']").value,
            this.template.querySelector("[data-id='OnerousUnreviewableStartDate__c']").value,
            this.template.querySelector("[data-id='MissingDueAmount__c']")?.value,
            this.template.querySelector("[data-id='DeclineComputationSupport__c']")?.value,
            this.template.querySelector("[data-id='CustomerRepentanceRefusal__c']")?.value,            
            this.template.querySelector("[data-id='BlockOnComputation__c']").value,
            this.template.querySelector("[data-id='EffectiveDate__c']").value,
            this.template.querySelector("[data-id='DeclarationDate__c']").value
        );
    }

    @api startActiveRepentant(dateDecorrenza, dateDichiarazione) {
        if (dateDecorrenza && new Date(dateDecorrenza).getTime() <= new Date().getTime() && dateDichiarazione && new Date(dateDecorrenza).getTime() <= new Date(dateDichiarazione).getTime()) {
            this.dateDichiarazione = dateDichiarazione;
            this.dateDecorrenza = dateDecorrenza;
            if(this.checkComuniNonAffidatari(new Date(this.dateDecorrenza), new Date(this.dateDichiarazione))) return;
            this.handleRepentant();
        } else {
            this.showMessage(
                "Attenzione!",
                dateDecorrenza && dateDichiarazione? "La data di decorrenza non può essere maggiore della data dichiarazione e non può essere maggiore della data odierna" : "Popolare Data Decorrenza / Dichiarazione",
                "error"
            );
            this.dateDecorrenza=null;
            this.disabled=false;
        }
    }

    checkComuniNonAffidatari(dateDecorrenza, dateDichiarazione){
        
        if(!(this.cityData?.TARIManagingStartDate__c && this.cityData?.TARIManagingEndDate__c && this.cityData?.CutOverEndDate__c)){
            this.showMessage(
                "Attenzione!",
                this.cityData.CityNotManagedAlert__c? this.cityData.CityNotManagedAlert__c : "Comune Non Gestito",
                "error"
            );
            this.dateDecorrenza=null;
            this.disabled=false;
            return true;
        }

        if( (dateDecorrenza.getTime() < new Date(this.cityData?.TARIManagingStartDate__c).getTime() || dateDecorrenza.getTime() > new Date(this.cityData?.TARIManagingEndDate__c).getTime())){
            this.showMessage(
                "Attenzione!",
                this.cityData.CityNotManagedAlert__c? this.cityData.CityNotManagedAlert__c : "Comune Non Gestito",
                "error"
            );
            this.dateDecorrenza=null;
            this.disabled=false;
            return true;
        }
        
        if( dateDichiarazione.getTime() > new Date(this.cityData?.CutOverEndDate__c).getTime()){
            this.showMessage(
                "Attenzione!",
                "La data di contatto è successiva a quella di fine cut-over",
                "error"
            );
            this.dateDichiarazione=null;
            this.disabled=false;
            return true;
        }
        return false;
    }

    async getTablesConfig(){
        let wrp = await getTables({ comune: this.city, sottotipo: this.sottotipo });
        let {termsTable : data, termsAdministration: terms, cityData} = wrp;
        this.cityData=cityData?.[0];
        this.loading--;
        if (data?.length) {
            console.log("data " + data[0].Id);
            this.termsAdministration= terms;
            this.period = data[0];
        }else{
            console.log("#getTablesConfig -> Data not found! ");
            this.skipCheck=true;
        }
    }

    handleRepentant() {
        console.log("order ->" + this.city);
        console.log("Richiesta Subentro ");

        try{
            //let data = await getPeriods({ comune: this.city, sottotipo: this.sottotipo });
            //let terms = await getTerms({ comune: this.city });
            //let wrp = await getTables({ comune: this.city, sottotipo: this.sottotipo });
            //let {termsTable : data, termsAdministration: terms, cityData} = wrp;
            //this.cityData=cityData?.[0];
            //if(this.checkComuniNonAffidatari(new Date(this.dateDecorrenza))) return;
            if (this.period) {
                this.skipCheck=false;
                this.checkData(this.period, this.termsAdministration);
            }
        }catch(error) {
            console.log("#ErrorGetPeriods -> " + JSON.stringify(error));
            this.skipCheck=true;
        }finally{
            this.finish();
        }
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

        if (declarationDate.getTime() >= this.limitDateY.getTime()) {
            console.log("Periodo non ravv Z");
            this.periodType ="Z";
            if(!this.isCompanyMms)   this.showMessage("Attenzione!", this.period.PopupZ__c, " error", "sticky");
            return;
        } else {
            console.log("Periodo Ravvedibile Y");
            this.periodType ="Y";
            this.calculateMissedDue(terms, declarationDate);
            if(!this.isCompanyMms)   this.showMessage("Attenzione!", this.period.PopupY__c, " error", "sticky");
        }
    }

    showMessage(title, message, variant, mode) {
        //this.loading=0;
        const toastErrorMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(toastErrorMessage);
    }

    finish() {
        const evt = CustomEvent("end_algorithm", {
            detail: {
                dateX: this.limitDateX? this.getFormattedDate(new Date(this.limitDateX.getDate() + 1 )) : null,
                dateY: this.limitDateY? this.getFormattedDate(new Date(this.limitDateY.getDate() + 1 )) : null,
                missedDue: this.missedDueDate,
                period: this.periodType
            }
        });

        this.dispatchEvent(evt);

        if(this.recordId)    this.populateFormFields(evt);
        this.limitDateX=null;
        this.limitDateY=null;
        this.missedDueDate=null;//reset data to avoid conflicts
        this.disabled=false;
    }

    populateFormFields(event) {//function executed on parent context
        console.log('###Missed Due Event >>> ');
        const revDate = this.template.querySelector("[data-id='OnerousReviewableStartDate__c']");
        if(revDate) revDate.value = event.detail.dateX;

        const unrevDate = this.template.querySelector("[data-id='OnerousUnreviewableStartDate__c']");
        if(unrevDate)   unrevDate.value = event.detail.dateY;

        let isPeriodY = event.detail.period=="Y";

        //const missingDueAmount = this.template.querySelector("[data-id='MissingDueAmount__c']");
        //if(missingDueAmount)    missingDueAmount.required = event.detail.missedDue? true : false, missingDueAmount.disabled = !isPeriodY; missingDueAmount.value = isPeriodY? missingDueAmount.value : "";        
        
        const decline = this.template.querySelector("[data-id='DeclineComputationSupport__c']");
        if(decline) decline.required = isPeriodY;

        const refusal = this.template.querySelector("[data-id='CustomerRepentanceRefusal__c']");
        if(refusal) refusal.required=isPeriodY;

        this.template.querySelector("[data-id='BlockOnComputation__c']").value = isPeriodY? "Y" : "N";
    }

    getFormattedDate(date){
        let month = date.getMonth()+1;
        month = month<10? "0"+month : month;
        let day = date.getDate()<10? "0"+date.getDate() : date.getDate();
        return date.getFullYear()+'-'+month+'-'+day;
    }

    subscribeMC() {
		// recordId is populated on Record Pages, and this component
		// should not update when this component is on a record page.
        this.subscription = subscribe(
            this.messageContext,
            BUTTONMC,
            (mc) => {if(this.sessionid==mc.sessionid) this.eventButton = mc.message},
            //{ scope: APPLICATION_SCOPE }
        );
		// Subscribe to the message channel
	}

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}
