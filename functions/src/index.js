const admin = require('firebase-admin');
admin.initializeApp();

const { moderateComment, onCommentWritten } = require('./comments');
const { onVoteWritten, recalculatePersona } = require('./stats');
const { takeDeadlineSnapshot } = require('./snapshots');
const { kakaoCustomToken } = require('./kakaoAuth');
const { sendDeadlineReminders, sendReengagementNotifications, saveFcmToken } =
  require('./notifications');

exports.moderateComment = moderateComment;
exports.onCommentWritten = onCommentWritten;
exports.onVoteWritten = onVoteWritten;
exports.recalculatePersona = recalculatePersona;
exports.takeDeadlineSnapshot = takeDeadlineSnapshot;
exports.kakaoCustomToken = kakaoCustomToken;
exports.sendDeadlineReminders = sendDeadlineReminders;
exports.sendReengagementNotifications = sendReengagementNotifications;
exports.saveFcmToken = saveFcmToken;
