/* jshint esversion: 8 */
/* 
This Function will notify the article author and/or a comment OP about a new comment.
If the comment is a reply to a previous comment (submission), the OP will be notified.
If not, only the author of the post will be informed.
TODO:
- Add subscribe/unsubscribe links
- Email only if the user has a subscription
- Find the post author, if there is not one, use the site author's email
- Make sure there is a valid user-authentication-token in the submission
- Only send mail to validated email addresses
*/
const nodemailer = require('nodemailer');
const request = require('request-promise-native');


exports.handler = async function(event, context) {
  try {
    const body = await main(JSON.parse(event.body));
    return { statusCode: 200, body };
  } catch (err) {
    return { statusCode: 500, body: err.toString() };
  }
};

// async..await is not allowed in global scope, must use a wrapper
async function main(submission) {

  console.log(submission);

  // The link back to the submission
  let submissionURL = submission.site_url + '/' + submission.data.page_id + ".html#" + submission.id;

  // Construct the mail body for the OP
  let mailTextBody = `${submission.name} به دیدگاهت رو سایت مهدیکس [جواب](${submissionURL}) داد:

  ${submission.body}`;

  let mailHTMLBody = `<div dir="rtl">
  <p>${submission.name} به دیدگاهت رو سایت مهدیکس <a href="${submissionURL}">جواب</a> داد:</p>
  <blockquote>${submission.body}</blockquoe></div>`;

  // create reusable transporter object using the default SMTP transport
  let transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: 465,
    secure: true, // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    }
  });

  // Notify OP if this is a reply to a previous comment
  if (submission.data['reply-to']) {
    // Get OP's email address
    let opEmail = await getOPEmail(submission.data['reply-to']);
    // send mail with defined transport object
    let info = await transporter.sendMail({
      from: `mehdix.ir <${submission.id}@mehdix.ir>`,
      to: opEmail,
      subject: `${submission.name} جواب داد ✔`,
      text: mailTextBody,
      html: mailHTMLBody
    });
  }

  // Always inform the post author about new comments.
  let info = await transporter.sendMail({
    from: `mehdix.ir <${submission.id}@mehdix.ir>`,
    to: process.env.NOTIFICATIONS_EMAIL,
    subject: `${submission.name} داد سخن داد ✔`,
    text: mailTextBody,
    html: mailHTMLBody
  });

  return Promise.resolve(`Message sent: ${info.messageId}`);
}

async function getOPEmail(replyToId) {
  let options = {
    uri: (
      `https://api.netlify.com/api/v1/sites/${process.env.NETLIFY_SITE_ID}` +
      `/forms/${process.env.NETLIFY_FORM_ID}/submissions/${replyToId}`),
    qs: {
      access_token: process.env.NETLIFY_ACCESS_TOKEN
    },
    json: true
  };

  return Promise.resolve(
    request(options)
    .then((submission) => {
      return submission.email;
    })
    .catch((err) => {
      console.log(err);
    })
  );
}
