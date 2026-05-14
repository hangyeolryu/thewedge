const admin = require('firebase-admin');
admin.initializeApp();

const { moderateComment, onCommentWritten } = require('./comments');
const { onVoteWritten, recalculatePersona } = require('./stats');
const { takeDeadlineSnapshot } = require('./snapshots');
const { kakaoCustomToken } = require('./kakaoAuth');

exports.moderateComment = moderateComment;
exports.onCommentWritten = onCommentWritten;
exports.onVoteWritten = onVoteWritten;
exports.recalculatePersona = recalculatePersona;
exports.takeDeadlineSnapshot = takeDeadlineSnapshot;
exports.kakaoCustomToken = kakaoCustomToken;
