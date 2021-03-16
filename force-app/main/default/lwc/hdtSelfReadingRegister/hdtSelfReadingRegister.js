import { LightningElement, api, track, wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';


export default class HdtSelfReadingRegister extends LightningElement {


    @api rowObj;
    @api commodity;
    @api isRetroactive;
    @api isVolture;
    @api isVisible;
    advanceError;

    get visibilityClass() {
        return this.isVisible === true ? 'slds-show' : 'slds-hide';
    }

    registerObjEle = [
        {id: 1, name: "readingType", label:"Tipo Lettura ", type: "text", value: null, disabled:true, visible:false},
        {id: 2, name: "readingDate", label:"Data Ultima Lettura ", type: "date", value: null, disabled:true, visible:true},
        {id: 3, name: "readingOldValue", label:"Ultima Lettura ", type: "number", value: null, disabled:true, visible:true},
        {id: 4, name: "readingValue", label:"Nuova Lettura ", type: "number", value: null, disabled:false, visible:true},
        {id: 5, name: "readingBand", label:"Fascia ", type: "text", value: null, disabled:true, visible:false},
        {id: 6, name: "readingSerialNumber", label:"Matricola ", type: "text", value: null, disabled:true, visible:false}
    ];

    registerObjGas = [
        {id:1, name: "readingDate", label:"Data Ultima Lettura ", type: "date", value: null, disabled:true, visible:true},
        {id:2, name: "readingOldValue", label:"Ultima Lettura ", type: "number", value: null, disabled:true, visible:true},
        {id:3, name: "readingValue", label:"Nuova Lettura ", type: "number", value: null, disabled:false, visible:true},
        {id:4, name: "readingSerialNumber", label:"Matricola ", type: "text", value: null, disabled:true, visible:true},
        {id:5, name: "readingType", label:"Tipo ", type: "text", value: null, disabled:true, visible:false},
        {id:6, name: "readingBand", label:"Fascia ", type: "text", value: null, disabled:true, visible:false},
        {id:7, name: "readingRegister", label:"Registro", type: "text", value: null, disabled:true, visible:false},
        {id:8, name: "readingUnit", label:"Unita di Misura", type: "text", value: null, disabled:true, visible:false}
    ];

    @track registerObj = [];

    @track registerRet = [];
    



    connectedCallback(){

        this.registerObj = this.commodity === 'Energia Elettrica' ? this.registerObjEle : this.registerObjGas;

        console.log(this.rowObj.number);

        if(this.commodity === 'Energia Elettrica'){

            for(let i=0; i<Object.keys(this.registerObj).length; ++i){

                this.registerObj[i].label += 'F' + this.rowObj.headerIndex;

            }
        } else if(this.commodity === 'Gas'){

            for(let i=0; i<Object.keys(this.registerObj).length; ++i){

                if(this.registerObj[i].name === 'readingDate'
                || this.registerObj[i].name === 'readingSerialNumber'
                || this.registerObj[i].name === 'readingOldValue'
                || this.registerObj[i].name === 'readingValue'){

                    this.registerObj[i].label += this.rowObj.number;

                }

            }

        }

        // Per l'autolettura il tasto Verifica Ultima Lettura è obbligatorio, quindi inizialmente disabilitiamo tutto. 
        if (!this.isVolture) {
            for(let i=0; i<Object.keys(this.registerObj).length; ++i){
                if (this.registerObj[i].name === 'readingValue') {
                    this.registerObj[i].disabled = true;
                }
            }
        }

    }


    @api
    checkDate(readingCustomerDate){

        console.log('Method Called Correctly');

        console.log('isRetroactive? '+this.isRetroactive);

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();

        //today = dd + '/' + mm + '/' + yyyy;
        today = yyyy + '-' + mm + '-' + dd;

        if(Date.parse(readingCustomerDate) > Date.parse(today)){

            this.advanceError = 'Impossibile inserire una data futura!';

        }

        if(!this.isRetroactive){

            var index = this.registerObj.findIndex(p => p.label.name === 'readingDate');

            if(Date.parse(readingCustomerDate) <= Date.parse(this.registerObj[index].value)){

                this.advanceError = 'Impossibile inserire una data precedente o uguale all\'ultima lettura!'

            } else {

                this.advanceError = undefined;

            }

        }

        return this.advanceError;

    }

    @api
    handleLastReading(jsonReading){

        console.log('Method Called Correctly');

        var readingObj = JSON.parse(jsonReading);

        console.log(readingObj);

        if (this.commodity === 'Energia Elettrica') {
            this.isVisible = (this.rowObj.id <= readingObj.length);
        } else if (this.commodity === 'Gas') {
            this.isVisible = (this.rowObj.id === 'Meter' || (this.rowObj.id === 'Corrector' && readingObj.length === 2));
        }

        var indexIn = readingObj.findIndex(p => p.register == this.rowObj.number);

        console.log(indexIn);

        if(indexIn == -1){

            var indexCustomerReading = this.registerObj.findIndex(p => p.name === 'readingValue');

            this.registerObj[indexCustomerReading].disabled = true;

        } else{
            if (!this.isVolture) {
                var indexCustomerReading = this.registerObj.findIndex(p => p.name === 'readingValue');
                this.registerObj[indexCustomerReading].disabled = false;
            }

            for(const property in readingObj[indexIn]){

                console.log(property);

                var indexOut = this.registerObj.findIndex(p => {

                    /*if(property == "Lettura"){

                        return this.commodity === "Energia Elettrica" ? p.label == property+' '+this.rowObj.number 
                        : this.commodity === "Gas" ? p.label == property 
                        : null;

                    } else{

                        return p.label.includes(property);

                    }*/
                    
                    return p.name === property;

                });

                console.log("indexOut "+indexOut);

                if(indexOut >= 0){

                    console.log(readingObj[indexIn][property]);

                    this.registerObj[indexOut].value = readingObj[indexIn][property];

                    console.log(this.registerObj);
                
                }          
            }
        }
    }

    @api
    handleSave(){

        try {
            this.registerObj.forEach(element => {

                if(element.disabled == false && (element.value == null || element.value == '' || element.value == undefined)){
    
                    this.advanceError = 'Impossibile procedere: Nuova Lettura deve essere valorizzata.';
    
                } 
    
            });
    
            console.log('advanceError: ' + this.advanceError);
    
            if(this.advanceError != undefined){
    
                return this.advanceError;
    
            } else{
    
                console.log('Filling the Array: ' + this.registerObj + ' - ' + this.rowObj);
    
                this.registerRet = 
                    {
                        ['ReadingType'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingType')].value,
                        ['ReadingBand'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingBand')].value,
                        ['ReadingSerialNumber'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingSerialNumber')].value,
                        ['ReadingValue'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingValue')].value,
                        ['ReadingOldValue'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingOldValue')].value,
                        ['ReadingRegister'+this.rowObj.id+'__c']:this.commodity === 'Gas' ? 
                        this.registerObj[this.registerObj.findIndex(p => p.name === 'readingRegister')].value
                        : null,
                        ['ReadingUnit'+this.rowObj.id+'__c']:this.commodity === 'Gas' ?
                        this.registerObj[this.registerObj.findIndex(p => p.name === 'readingUnit')].value 
                        : null
                    };
    
                    console.log('Array filled with: ' + this.registerRet + ' keys: ' + Object.keys(this.registerRet));
    
                    return this.registerRet;
    
            }
        } catch (e) {
            console.log('exception ' + e);
            throw e;
        }

    }


    handleChange(event){

        console.log(event.target.label);

        console.log(event.target.value);

        console.log('isRetroactive? '+this.isRetroactive);

        if(event.target.label.includes('Nuova Lettura') && !this.isRetroactive){
            
            var indexReading = this.registerObj.findIndex(p => {

                return p.name === 'readingOldValue';

            });

            const previousReading = this.registerObj[indexReading].value;
            const newReading = event.target.value;
            // Mostriamo l'errore solo dopo che l'operatore inserisce almeno lo stesso numero di cifre della vecchia lettura. 
            if(newReading.length >= previousReading.length && parseInt(newReading) < parseInt(previousReading)){

                this.advanceError = 'Impossibile inserire lettura inferiore all\'ultima lettura';

                event.target.setCustomValidity(this.advanceError);

            }else if(event.target.value > 99999999999){

                this.advanceError = 'Valore lettura troppo elevato';

                event.target.setCustomValidity(this.advanceError);

            } else {

                this.registerObj[this.registerObj.findIndex(p => p.name === 'readingValue')].value = event.target.value; 

                this.advanceError = undefined;

                event.target.setCustomValidity("");

            }

        } else {

            this.registerObj[this.registerObj.findIndex(p => p.name === 'readingValue')].value = event.target.value; 

            this.advanceError = undefined;

            event.target.setCustomValidity("");

        }

        event.target.reportValidity();


    }

}