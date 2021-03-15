import { LightningElement, api, track, wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';


export default class HdtSelfReadingRegister extends LightningElement {


    @api header;
    @api rowObj;
    @api commodity;
    @api isRetroactive;
    @api isVolture;
    advanceError;

    registerObjEle = [
        {id: 1, label:"Tipo Lettura ", type: "text", value: null, disabled:true, visible:false},
        {id: 2, label:"Data Lettura ", type: "date", value: null, disabled:true, visible:true},
        {id: 3, label:"Lettura ", type: "number", value: null, disabled:true, visible:true},
        {id: 4, label:"Lettura da Cliente ", type: "number", value: null, disabled:false, visible:true},
        {id: 5, label:"Fascia ", type: "text", value: null, disabled:true, visible:false},
        {id: 6, label:"Matricola ", type: "text", value: null, disabled:true, visible:true}
    ];

    registerObjGas = [
        {id:1, label:"Tipo ", type: "text", value: null, disabled:true, visible:true},
        {id:2, label:"Data Lettura", type: "date", value: null, disabled:true, visible:true},
        {id:3, label:"Lettura", type: "number", value: null, disabled:true, visible:true},
        {id:4, label:"Lettura da Cliente ", type: "number", value: null, disabled:false, visible:true},
        {id:5, label:"Mat. ", type: "text", value: null, disabled:true, visible:true},
        {id:6, label:"Fascia ", type: "text", value: null, disabled:true, visible:false},
        {id:7, label:"Registro", type: "text", value: null, disabled:true, visible:false},
        {id:8, label:"Unita di Misura", type: "text", value: null, disabled:true, visible:false}
    ];

    @track registerObj = [];

    @track registerRet = [];
    



    connectedCallback(){

        this.registerObj = this.commodity === 'Energia Elettrica' ? this.registerObjEle : this.registerObjGas;

        console.log(this.rowObj.number);

        if(this.commodity === 'Energia Elettrica'){

            for(let i=0; i<Object.keys(this.registerObj).length; ++i){

                this.registerObj[i].label += this.rowObj.number;

            }
        } else if(this.commodity === 'Gas'){

            for(let i=0; i<Object.keys(this.registerObj).length; ++i){

                if(this.registerObj[i].label.includes("Tipo") 
                || this.registerObj[i].label.includes("Mat.")
                || this.registerObj[i].label.includes("Fascia")
                || this.registerObj[i].label.includes("Lettura da Cliente")){

                    this.registerObj[i].label += this.rowObj.number;

                }

            }

        }

        // Per l'autolettura il tasto Verifica Ultima Lettura è obbligatorio, quindi inizialmente disabilitiamo tutto. 
        if (!this.isVolture) {
            for(let i=0; i<Object.keys(this.registerObj).length; ++i){
                if (this.registerObj[i].label.includes("Lettura da Cliente")) {
                    this.registerObj[i].disabled = true;
                }
            }
        }

    }


    @api
    checkDate(readingCustomerDate){

        console.log('Method Called Correctly');

        console.log('isRetroactive? '+this.isRetroactive);

        if(!this.isRetroactive){

            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = today.getFullYear();

            //today = dd + '/' + mm + '/' + yyyy;
            today = yyyy + '-' + mm + '-' + dd;

            var index = this.registerObj.findIndex(p => p.label.includes("Data Lettura"));

            if(Date.parse(readingCustomerDate) > Date.parse(today)){

                this.advanceError = 'Impossibile inserire una data futura!';

            } else if(Date.parse(readingCustomerDate) <= Date.parse(this.registerObj[index].value)){

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

        var indexIn = readingObj.findIndex(p => p.register == this.rowObj.number);

        console.log(indexIn);

        if(indexIn == -1){

            var indexCustomerReading = this.registerObj.findIndex(p => p.label.includes("Lettura da Cliente"));

            this.registerObj[indexCustomerReading].disabled = true;

        } else{
            if (!this.isVolture) {
                var indexCustomerReading = this.registerObj.findIndex(p => p.label.includes("Lettura da Cliente"));
                this.registerObj[indexCustomerReading].disabled = false;
            }

            for(const property in readingObj[indexIn]){

                console.log(property);

                var indexOut = this.registerObj.findIndex(p => {

                    if(property == "Lettura"){

                        return this.commodity === "Energia Elettrica" ? p.label == property+' '+this.rowObj.number 
                        : this.commodity === "Gas" ? p.label == property 
                        : null;

                    } else{

                        return p.label.includes(property);

                    }
                    
                
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
    
                    this.advanceError = 'Impossibile procedere: Lettura da Cliente deve essere valorizzata';
    
                } 
    
            });
    
            console.log('advanceError: ' + this.advanceError);
    
            if(this.advanceError != undefined){
    
                return this.advanceError;
    
            } else{
    
                console.log('Filling the Array: ' + this.registerObj + ' - ' + this.rowObj);
    
                this.registerRet = 
                    {
                        ['ReadingType'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.label.includes("Tipo"))].value,
                        ['ReadingBand'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.label.includes("Fascia"))].value,
                        ['ReadingSerialNumber'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.label.includes("Mat"))].value,
                        ['ReadingValue'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.label.includes("Lettura da Cliente"))].value,
                        ['ReadingRegister'+this.rowObj.id+'__c']:this.commodity === 'Gas' ? 
                        this.registerObj[this.registerObj.findIndex(p => p.label.includes("Registro"))].value 
                        : null,
                        ['ReadingUnit'+this.rowObj.id+'__c']:this.commodity === 'Gas' ?
                        this.registerObj[this.registerObj.findIndex(p => p.label.includes("Unita"))].value 
                        : null
                    };
    
                /*this.registerRet = 
                    {id: this.rowNumber, 
                    redingType:this.registerObj[this.registerObj.findIndex(p => p.label.includes("Tipo"))].value,
                    readingDate:this.registerObj[this.registerObj.findIndex(p => p.label.includes("Data"))].value,
                    band:this.registerObj[this.registerObj.findIndex(p => p.label.includes("Fascia"))].value,
                    meterCode:this.registerObj[this.registerObj.findIndex(p => p.label.includes("Mat"))].value,
                    reading:this.registerObj[
                        this.registerObj.findIndex(p => this.commodity === 'Energia Elettrica' ? p.label == 'Lettura ' + this.rowNumber 
                        : this.commodity === 'Gas' ? p.label == 'Lettura' : 0)
                        ].value,
                    readingCustomer:this.registerObj[this.registerObj.findIndex(p => p.label.includes("Lettura da Cliente"))].value,
                    register:this.commodity === 'Gas' ? 
                        this.registerObj[this.registerObj.findIndex(p => p.label.includes("Registro"))].value 
                        : null,
                    unitMeasure:this.commodity === 'Gas' ?
                        this.registerObj[this.registerObj.findIndex(p => p.label.includes("Unita"))].value 
                        : null
                    };*/
    
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

        if(event.target.label.includes("Lettura da Cliente") && !this.isRetroactive){
            
            var indexReading = this.registerObj.findIndex(p => {

                return this.commodity === "Energia Elettrica" ? p.label == 'Lettura '+this.rowObj.number
                : this.commodity === "Gas" ? p.label == 'Lettura'
                : null;

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

                this.registerObj[this.registerObj.findIndex(p => p.label.includes("Lettura da Cliente"))].value = event.target.value; 

                this.advanceError = undefined;

                event.target.setCustomValidity("");

            }

        } else {

            this.registerObj[this.registerObj.findIndex(p => p.label.includes("Lettura da Cliente"))].value = event.target.value; 

            this.advanceError = undefined;

            event.target.setCustomValidity("");

        }

        event.target.reportValidity();


    }

}