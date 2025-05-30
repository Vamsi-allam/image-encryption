# Deploying Image Encryption App to Vercel

This guide explains how to deploy your Flutter web application to Vercel.

## Prerequisites

- Flutter SDK set up for web development
- Git repository for your project
- A Vercel account (sign up at [vercel.com](https://vercel.com))
- Firebase project configured

## Step 1: Prepare Your Flutter Project for Web

Ensure your Flutter project is configured for web:

```bash
flutter channel stable
flutter upgrade
flutter config --enable-web
```

## Step 2: Build Your Flutter Web App

Build a production version of your Flutter web application:

```bash
cd d:\flutterprojects\image_encryption_app
flutter build web --release
```

This will create optimized files in the `build/web` directory.

## Step 3: Set Up Vercel CLI (Optional)

You can deploy via the Vercel website or using the Vercel CLI:

```bash
npm install -g vercel
```

## Step 4: Create Vercel Configuration

Create a `vercel.json` file in your project root with the following content:

```json
{
  "version": 2,
  "builds": [
    {
      "src": "build/web/**/*",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/build/web/$1"
    },
    {
      "src": "/(.+\\.[a-z0-9]+)$",
      "dest": "/build/web/$1"
    },
    {
      "src": "/(.*)",
      "dest": "/build/web/index.html"
    }
  ]
}
```

## Step 5: Configure Firebase for Production

1. Update your Firebase configuration in the web app to use your production Firebase project.
2. Make sure all required Firebase services (Authentication, Firestore, Storage) are properly configured.

## Step 6: Deploy to Vercel

### Option 1: Using Vercel CLI

```bash
cd d:\flutterprojects\image_encryption_app
vercel login
vercel
```

Follow the prompts to complete the deployment.

### Option 2: Using Vercel Website

1. Push your code to your Git repository (GitHub, GitLab, or Bitbucket)
2. Log in to [Vercel Dashboard](https://vercel.com/dashboard)
3. Click "New Project"
4. Import your repository
5. Configure the project:
   - Set the Framework Preset to "Other"
   - Set the Build Command to `flutter build web --release`
   - Set the Output Directory to `build/web`
   - Add any required environment variables for Firebase
6. Click "Deploy"

## Step 7: Configure Custom Domain (Optional)

1. In your Vercel project dashboard, go to "Settings" > "Domains"
2. Add your custom domain and follow the verification process

## Step 8: Environment Variables

Add any necessary environment variables in the Vercel project settings:

1. Go to your project in the Vercel dashboard
2. Navigate to "Settings" > "Environment Variables"
3. Add any Firebase API keys or other configuration variables
   - Note: Public Firebase config variables are typically embedded in your app and don't need to be added here

## Step 9: Verify Deployment

1. Test your deployed application thoroughly
2. Verify that Firebase services are working properly
3. Check authentication, image encryption/decryption, and storage features

## Troubleshooting

- **404 Errors**: Make sure your routing configuration in `vercel.json` is correct
- **Firebase Connection Issues**: Verify your Firebase project is properly configured and that the domain is authorized in Firebase console
- **CORS Issues**: Add your Vercel domain to the authorized domains in Firebase console
- **Build Failures**: Check Vercel logs for details on build issues

## Auto-Deployments

With your repository connected to Vercel, any push to your main branch will automatically trigger a new deployment.

---

For more information, refer to the [Vercel Documentation](https://vercel.com/docs) and [Flutter Web Deployment Guide](https://flutter.dev/docs/deployment/web).
