import type { Metadata } from "next"
import Link from "next/link"

export const metadata: Metadata = {
  title: "Terms of Use",
  description: "Terms of use for Unit, the adaptive gym logger for iOS.",
}

export default function TermsPage() {
  return (
    <section className="pt-32 pb-unit-xxl md:pb-[96px]">
      <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg">
        <article className="prose-page">
          <h1>Terms of Use</h1>
          <p className="last-updated">Last updated: April 13, 2026</p>

          <p>
            These Terms of Use (&quot;Terms&quot;) govern your use of the Unit
            mobile application (&quot;the App&quot;) developed by Efe Bakir
            (&quot;we,&quot; &quot;us,&quot; or &quot;our&quot;). By
            downloading or using Unit, you agree to these Terms.
          </p>

          <h2>License</h2>
          <p>
            We grant you a limited, non-exclusive, non-transferable, revocable
            license to use Unit for your personal, non-commercial fitness
            tracking purposes, subject to these Terms and the Apple Media
            Services Terms and Conditions.
          </p>

          <h2>Purchase and Payment</h2>
          <p>
            Unit offers in-app purchases through the Apple App Store. All
            payment processing is handled by Apple. We do not handle your
            payment information.
          </p>
          <ul>
            <li>
              Pricing is set in the App Store and may vary by region
            </li>
            <li>
              Refunds are subject to Apple&apos;s refund policies
            </li>
          </ul>

          <h2>Acceptable Use</h2>
          <p>You agree not to:</p>
          <ul>
            <li>Reverse engineer, decompile, or disassemble the App</li>
            <li>
              Copy, modify, or create derivative works based on the App
            </li>
            <li>
              Use the App for any unlawful purpose or in violation of any
              applicable laws
            </li>
            <li>
              Redistribute, sublicense, or make the App available to third
              parties
            </li>
          </ul>

          <h2>Intellectual Property</h2>
          <p>
            Unit, including its design, code, visual identity, and content, is
            the intellectual property of Efe Bakir and is protected by
            applicable copyright and intellectual property laws.
          </p>

          <h2>Your Data</h2>
          <p>
            All workout data you create in Unit is stored locally on your
            device. You are responsible for maintaining backups of your device.
            We are not responsible for data loss resulting from device failure,
            loss, or App deletion.
          </p>

          <h2>Disclaimer of Warranties</h2>
          <p>
            Unit is provided &quot;as is&quot; and &quot;as available&quot;
            without warranties of any kind, either express or implied, including
            but not limited to implied warranties of merchantability, fitness
            for a particular purpose, and non-infringement.
          </p>
          <p>
            Unit is a fitness tracking tool, not medical advice. You are solely
            responsible for your training decisions and physical safety. Consult
            a qualified professional before beginning any exercise program.
          </p>

          <h2>Limitation of Liability</h2>
          <p>
            To the maximum extent permitted by applicable law, Efe Bakir shall
            not be liable for any indirect, incidental, special, consequential,
            or punitive damages, or any loss of data, use, or profits, arising
            out of or related to your use of the App.
          </p>

          <h2>Changes to the App and Service</h2>
          <p>
            We reserve the right to modify, update, or discontinue the App at
            any time without prior notice. We are not obligated to provide
            updates, enhancements, or support indefinitely.
          </p>

          <h2>Changes to These Terms</h2>
          <p>
            We may update these Terms from time to time. Changes will be posted
            on this page with an updated &quot;Last updated&quot; date.
            Continued use of the App after changes constitutes acceptance of the
            revised Terms.
          </p>

          <h2>Governing Law</h2>
          <p>
            These Terms shall be governed by and construed in accordance with
            the laws of the Netherlands, without regard to conflict of law
            principles.
          </p>

          <h2>Contact</h2>
          <p>
            If you have questions about these Terms, contact us at:
          </p>
          <ul>
            <li>Email: efeec.bakir@gmail.com</li>
            <li>Developer: Efe Bakir</li>
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
