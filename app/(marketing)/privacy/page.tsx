import type { Metadata } from "next"
import Link from "next/link"

export const metadata: Metadata = {
  title: "Privacy Policy",
  description:
    "Unit privacy policy. Your workout data stays on your device.",
}

export default function PrivacyPage() {
  return (
    <section className="pt-32 pb-unit-xxl md:pb-[96px]">
      <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg">
        <article className="prose-legal">
          <h1>Privacy Policy</h1>
          <p className="last-updated">Last updated: April 13, 2026</p>

          <p>
            Unit (&quot;the App&quot;) is developed and operated by{" "}
            Efe Bakir. This
            Privacy Policy explains how we handle your information when you use
            Unit.
          </p>

          <h2>Summary</h2>
          <p>
            Unit is designed with privacy as a default. Your workout data stays
            on your device. We do not collect, transmit, or store your personal
            information on our servers.
          </p>

          <h2>Data Storage</h2>
          <p>
            All data you create in Unit — exercises, workout sessions, cycles,
            progression rules, and set entries — is stored locally on your
            device using Apple&apos;s SwiftData framework. This data is not
            transmitted to any external server.
          </p>
          <p>
            If you delete the App, your locally stored data will be removed from
            your device.
          </p>

          <h2>Data We Do Not Collect</h2>
          <ul>
            <li>We do not collect your name, email address, or contact information through the App</li>
            <li>We do not collect workout data or training history</li>
            <li>We do not use analytics or tracking frameworks</li>
            <li>We do not use advertising SDKs</li>
            <li>We do not sell, share, or transfer any data to third parties</li>
          </ul>

          <h2>Purchases</h2>
          <p>
            Unit offers in-app purchases processed entirely by Apple through the
            App Store. We do not receive or store your payment information.
            Purchase records are managed by your Apple ID.
          </p>

          <h2>HealthKit</h2>
          <p>
            Unit does not currently integrate with Apple HealthKit. If HealthKit
            integration is added in a future update, this policy will be updated
            and you will be asked for explicit permission before any health data
            is accessed.
          </p>

          <h2>Cookies and Web Tracking</h2>
          <p>
            This website does not use cookies, analytics scripts, or any form of
            visitor tracking.
          </p>

          <h2>Children&apos;s Privacy</h2>
          <p>
            Unit is not directed at children under the age of 13. We do not
            knowingly collect information from children.
          </p>

          <h2>Your Rights</h2>
          <p>
            Since Unit does not collect personal data, there is no personal data
            for us to delete, export, or modify. All your data is under your
            control on your device.
          </p>
          <p>
            If you have questions about your data or wish to make a
            privacy-related request, contact us at{" "}
            efeec.bakir@gmail.com.
          </p>

          <h2>Changes to This Policy</h2>
          <p>
            We may update this Privacy Policy from time to time. Changes will be
            posted on this page with an updated &quot;Last updated&quot; date.
            Continued use of the App after changes constitutes acceptance of the
            revised policy.
          </p>

          <h2>Contact</h2>
          <p>
            If you have questions about this Privacy Policy, contact us at:
          </p>
          <ul>
            <li>
              Email: efeec.bakir@gmail.com
            </li>
            <li>
              Developer:{" "}
              Efe Bakir
            </li>
          </ul>

          <div className="mt-12">
            <Link
              href="/"
              className="text-sm text-unit-text-secondary hover:text-unit-text-primary transition-colors"
            >
              &larr; Back to home
            </Link>
          </div>
        </article>
      </div>
    </section>
  )
}
