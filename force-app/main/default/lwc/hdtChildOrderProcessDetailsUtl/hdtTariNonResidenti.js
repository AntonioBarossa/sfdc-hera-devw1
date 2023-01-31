class comune {
    constructor(name, readOnly, getResident) {
        this.name = name;
        this.readOnly = readOnly;
        this.getResident = getResident;
    }
}

export const cities = [
    new comune("BORGO TOSSIGNANO", false, ()=>2),
    new comune("CASALFIUMANESE", false, ()=>2),
    new comune("CASTEL DEL RIO", false, ()=>2),
    new comune("CASTEL GUELFO DI BOLOGNA", false, ()=>2),
    new comune("CASTEL SAN PIETRO TERME", false, ()=>2),
    new comune("FONTANELICE", false, ()=>2),
    new comune("IMOLA", false, ()=>2),
    new comune("MARRADI", true, ()=>3),
    new comune("MEDICINA", false, ()=>2),
    new comune("PRIGNANO SULLA SECCHIA", true, ()=>4),
    new comune("RUSSI", false, ()=>2),
    new comune("SAN GIORGIO DI PIANO", false, ()=>3),
    new comune("SERRAMAZZONI", true, ()=>3),
    new comune("CAMPOGALLIANO", false, (mq) => {
        if(!mq && mq!==0)   return null;

        if (mq <= 50)   return 1;
        if (mq <= 80)   return 2;
        if (mq <= 100)  return 3;
        if (mq <= 120)  return 4;
        if (mq <= 140)  return 5;
        return 6;
    }),
    new comune("GRANAROLO DELL'EMILIA", false, (mq) => {
        if(!mq && mq!==0)   return null;

        if (mq <= 45)   return 1;
        if (mq <= 60)   return 2;
        if (mq <= 75)   return 3;
        if (mq <= 90)   return 4;
        if (mq <= 105)  return 5;
        return 6;
    }),
    new comune("MODENA", false, (mq) => {
        if(!mq && mq!==0)   return null;

        if (mq <= 50)   return 1;
        if (mq <= 80)   return 2;
        if (mq <= 100)  return 3;
        if (mq <= 120)  return 4;
        if (mq <= 140)  return 5;
        return 6;
    })

]
.reduce((result, elem)=>{
    result[elem.name] = elem;
    return result;
}, {});