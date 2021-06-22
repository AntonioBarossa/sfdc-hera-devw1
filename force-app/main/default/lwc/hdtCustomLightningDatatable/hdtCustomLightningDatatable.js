import LightningDatatable from 'lightning/datatable';
import customType from './hdtRowActionCustomType.html';
 
export default class HdtCustomLightningDatatable extends LightningDatatable {
    static customTypes = {
        customRowAction: {
            template: customType,
            typeAttributes: ['recordId']
        }
    }
}