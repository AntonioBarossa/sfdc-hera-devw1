import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveCityEligibility from '@salesforce/apex/HDT_LC_EligibilityCriteriaController.saveCityEligibility';

const allData = [
    { label: 'Alto Reno Terme', value: '40046', id:'1'},
    { label: 'Anzola dell\'Emilia', value: '40011', id:'2'},
    { label: 'Argelato', value: '40050', id:'3'},
    { label: 'Baricella', value: '40052', id:'4'},
    { label: 'Bentivoglio', value: '40010', id:'5'},
    { label: 'Bologna', value: '40121', id:'6'},
    { label: 'Bologna', value: '40122', id:'7'},
    { label: 'Bologna', value: '40123', id:'8'},
    { label: 'Bologna', value: '40124', id:'9'},
    { label: 'Bologna', value: '40125', id:'10'},
    { label: 'Bologna', value: '40126', id:'11'},
    { label: 'Bologna', value: '40127', id:'12'},
    { label: 'Bologna', value: '40128', id:'13'},
    { label: 'Bologna', value: '40129', id:'14'},
    { label: 'Bologna', value: '40130', id:'15'},
    { label: 'Bologna', value: '40131', id:'16'},
    { label: 'Bologna', value: '40132', id:'17'},
    { label: 'Bologna', value: '40133', id:'18'},
    { label: 'Bologna', value: '40134', id:'19'},
    { label: 'Bologna', value: '40135', id:'20'},
    { label: 'Bologna', value: '40136', id:'21'},
    { label: 'Bologna', value: '40137', id:'22'},
    { label: 'Bologna', value: '40138', id:'23'},
    { label: 'Bologna', value: '40139', id:'24'},
    { label: 'Bologna', value: '40140', id:'25'},
    { label: 'Bologna', value: '40141', id:'26'},
    { label: 'Borgo Tossignano', value: '40021', id:'27'},
    { label: 'Budrio', value: '40054', id:'28'},
    { label: 'Calderara di Reno', value: '40012', id:'29'},
    { label: 'Camugnano', value: '40032', id:'30'},
    { label: 'Casalecchio di Reno', value: '40033', id:'31'},
    { label: 'Casalfiumanese', value: '40020', id:'32'},
    { label: 'Castel d\'Aiano', value: '40034', id:'33'},
    { label: 'Castel del Rio', value: '40022', id:'34'},
    { label: 'Castel di Casio', value: '40030', id:'35'},
    { label: 'Castel Guelfo di Bologna', value: '40023', id:'36'},
    { label: 'Castel Maggiore', value: '40013', id:'37'},
    { label: 'Castel San Pietro Terme', value: '40024', id:'38'},
    { label: 'Castello d\'Argile', value: '40050', id:'39'},
    { label: 'Castenaso', value: '40055', id:'40'},
    { label: 'Castiglione dei Pepoli', value: '40035', id:'41'},
    { label: 'Crevalcore', value: '40014', id:'42'},
    { label: 'Dozza', value: '40060', id:'43'},
    { label: 'Fontanelice', value: '40025', id:'44'},
    { label: 'Gaggio Montano', value: '40041', id:'45'},
    { label: 'Galliera', value: '40015', id:'46'},
    { label: 'Granarolo dell\'Emilia', value: '40057', id:'47'},
    { label: 'Grizzana Morandi', value: '40030', id:'48'},
    { label: 'Imola', value: '40026', id:'49'},
    { label: 'Lizzano in Belvedere', value: '40042', id:'50'},
    { label: 'Loiano', value: '40050', id:'51'},
    { label: 'Malalbergo', value: '40051', id:'52'},
    { label: 'Marzabotto', value: '40043', id:'53'},
    { label: 'Medicina', value: '40059', id:'54'},
    { label: 'Minerbio', value: '40061', id:'55'},
    { label: 'Molinella', value: '40062', id:'56'},
    { label: 'Monghidoro', value: '40063', id:'57'},
    { label: 'Monte San Pietro', value: '40050', id:'58'},
    { label: 'Monterenzio', value: '40050', id:'59'},
    { label: 'Monzuno', value: '40036', id:'60'},
    { label: 'Mordano', value: '40027', id:'61'},
    { label: 'Ozzano dell\'Emilia', value: '40064', id:'62'},
    { label: 'Pianoro', value: '40065', id:'63'},
    { label: 'Pieve di Cento', value: '40066', id:'64'},
    { label: 'Sala Bolognese', value: '40010', id:'65'},
    { label: 'San Benedetto Val di Sambro', value: '40048', id:'66'},
    { label: 'San Giorgio di Piano', value: '40016', id:'67'},
    { label: 'San Giovanni in Persiceto', value: '40017', id:'68'},
    { label: 'San Lazzaro di Savena', value: '40068', id:'69'},
    { label: 'San Pietro in Casale', value: '40018', id:'70'},
    { label: 'Sant\'Agata Bolognese', value: '40019', id:'71'},
    { label: 'Sasso Marconi', value: '40037', id:'72'},
    { label: 'Valsamoggia', value: '40053', id:'73'},
    { label: 'Vergato', value: '40038', id:'74'},
    { label: 'Zola Predosa', value: '40069', id:'75'}
];

const dataRemoved = [];

export default class HdtEligibilityCriteriaConfiguration extends LightningElement {

    @api productid;
    storeData = [];
    @track dataToView = [];
    @track dataRemoved = dataRemoved;
    showTable = false;
    queryTerm;

    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };

    connectedCallback(event){
        for(var i=0; i<allData.length; i++){
            this.dataToView.push(allData[i]);
            this.storeData.push(allData[i]);
        }
    }

    handleOnchange(event) {
        console.log('# handleOnchange #');

        this.queryTerm = event.target.value;
        console.log('# search -> ' + this.queryTerm);

        if(this.queryTerm != null && this.queryTerm != '' && this.queryTerm != undefined){
            
            var lowerTerm = this.queryTerm.toLowerCase();
            console.log('# find: ' + lowerTerm );

            this.dataToView = [];
            for(var i=0; i<this.storeData.length; i++){
                var currentLabel = this.storeData[i].label.toLowerCase();
                var cap = this.storeData[i].value;

                if(currentLabel.startsWith(lowerTerm) || cap.startsWith(this.queryTerm)){
                    this.dataToView.push(this.storeData[i]);
                }
            }

        } else {
            this.dataToView = [];
            for(var i=0; i<this.storeData.length; i++){
                this.dataToView.push(this.storeData[i]);
            }
        }
    }

    searchField(event) {
        console.log('# searchField #');
    }

    searchCity(event){
        console.log('# searchCity #');
    }

    removeItem(event){
        console.log('# removeItem #');

        var itemId = event.currentTarget.getAttribute('data-id');
        var itemLabel = event.currentTarget.getAttribute('data-label');
        var itemValue = event.currentTarget.getAttribute('data-value');
        console.log('# Remove ' + itemId + '; ' + itemLabel + '; ' + itemValue);

        //find and remove item from filtered list
        let element = this.dataToView.find(ele  => ele.id === itemId);
        var index = this.dataToView.indexOf(element);
        this.dataToView.splice(index, 1);

        //find and remove item from stored list
        let storedEle = this.storeData.find(ele  => ele.id === itemId);
        var storedIdex = this.storeData.indexOf(storedEle);
        this.storeData.splice(storedIdex, 1);

        //insert item removed to removed items list
        var itemRemoved = { label: itemLabel, value: itemValue, id: itemId};
        this.dataRemoved.push(itemRemoved);

        if(!this.showTable){
            this.showTable = true;
        }
    }

    restoreItem(event){
        console.log('# restore item #');

        var itemId = event.currentTarget.getAttribute('data-id');
        var itemLabel = event.currentTarget.getAttribute('data-label');
        var itemValue = event.currentTarget.getAttribute('data-value');
        console.log('# To restore ' + itemId + '; ' + itemLabel + '; ' + itemValue);

        var itemRemoved = { label: itemLabel, value: itemValue, id: itemId};

        let element = this.dataRemoved.find(ele  => ele.id === itemId);
        var a = this.dataRemoved.indexOf(element);
        this.dataRemoved.splice(a, 1);

        //check if the item is already stored, todo -> "migliorare"
        let alreadyStored = this.storeData.find(ele  => ele.label === itemId);
        console.log('@@@ ' + alreadyStored);
        if(alreadyStored == null || alreadyStored == undefined){
            this.storeData.push(itemRemoved);
            this.storeData.sort(this.compare);
        }

        //check if the item is already present, todo -> "migliorare"
        let alreadyPresent = this.dataToView.find(ele  => ele.id === itemId);
        console.log('@@@ ' + alreadyPresent);
        if(alreadyPresent == null || alreadyPresent == undefined){
            this.dataToView.push(itemRemoved);
            this.dataToView.sort(this.compare);
        }

    }

    compare(a, b) {
        const labelA = a.label.toUpperCase();
        const labelB = b.label.toUpperCase();

        let comparison = 0;
        if (labelA > labelB) {
            comparison = 1;
        } else if (labelA < labelB) {
            comparison = -1;
        }
        return comparison;
    }


    saveAction(){
        console.log('# saveAction #');
        console.log('# cityLenght -> ' + this.storeData.length);

        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';

        /*for(var i=0; i<this.storeData.length; i++){
            console.log('# ' + this.storeData[i].label + ' - ' + this.storeData[i].value);
        }*/

        saveCityEligibility({productId: this.productid, dataReceived: JSON.stringify(this.storeData)})
        .then(result => {
            console.log('# save success #');
            console.log('# resp -> ' + result.success);

            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };

            if(result.success){
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';
            } else {
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';                    
            }

            this.error = undefined;

            setTimeout(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: toastObj.title,
                        message: toastObj.message,
                        variant: toastObj.variant
                    }),
                );
                this.spinnerObj.spinner = false;
            }, 5000);

        })
        .catch(error => {
            console.log('# save error #');
            console.log('# resp -> ' + result.message);

            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while saving Record',
                    message: error.message,
                    variant: 'error',
                }),
            );
            setTimeout(() => {
                
            }, 1000);
        });
    }

}