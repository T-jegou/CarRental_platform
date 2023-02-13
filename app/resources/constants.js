// map all error names to corresponding HTTP codes
const ERROR_MAPPING = {
    400: ['CastError', 'ValidationError'],
    500: ['MongoError', 'TokenExpiredError'],
    503: ['ServiceUnavailableError'],
    401: ['UnauthorizedError'],
    404: ['NotFoundError'],
    409: ['ConflictError'],
    403: ['ForbiddenError'],
    429: ['TooManyRequestsError'],
    422: ['UnprocessableEntityError'],
    412: ['PreconditionFailedError'],
    413: ['PayloadTooLargeError'],
    415: ['UnsupportedMediaTypeError'],
    501: ['NotImplementedError'],
    502: ['BadGatewayError'],
    504: ['GatewayTimeoutError'],
    507: ['InsufficientStorageError'],
    511: ['NetworkAuthenticationRequiredError'],
    418: ['IamATeapotError'],
    451: ['UnavailableForLegalReasonsError'],    
};

const EXCHANGE = 'reservations';
const QUEUE = 'reservation.process';

module.exports = {
    ERROR_MAPPING: ERROR_MAPPING,
    EXCHANGE: EXCHANGE,
    QUEUE: QUEUE
}