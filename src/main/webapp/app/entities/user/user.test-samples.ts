import { IUser } from './user.model';

export const sampleWithRequiredData: IUser = {
  id: '5b61fc5b-fbc3-41b7-a5d1-a501ab55b5b6',
  login: '6hV',
};

export const sampleWithPartialData: IUser = {
  id: '241c5475-70b8-4cde-a9b4-bc10a7147df3',
  login: 'Xq',
};

export const sampleWithFullData: IUser = {
  id: '0e216954-032d-4303-85e6-e31a7042326c',
  login: 'L-@ayBy\\@9ur1',
};
Object.freeze(sampleWithRequiredData);
Object.freeze(sampleWithPartialData);
Object.freeze(sampleWithFullData);
