
Here's the target infrastructure:

![alt text](/docs/Carplatform_ArchiDiagram.drawio.png "Architecture diagram")

## Set .env variables
```
cp .env.example .env
```
Fill the all the field of the new .env file with mongo database credential (You can choose the values you want)

## Project setup
```
npm install
```

## Run local database
```
docker-compose up -d
```

## Run test
```
npm test
```

## Run lint
```
npm lint
```

### Run
```
npm run dev
```
